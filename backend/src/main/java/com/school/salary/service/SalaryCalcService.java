package com.school.salary.service;

import com.school.salary.entity.*;
import com.school.salary.common.BizException;
import com.school.salary.repository.*;
import com.school.salary.util.JsonUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 工资计算引擎
 * 核心流程：规则匹配 → 参数合并 → 分步计算 → 快照固化 → 明细生成 → 工资单聚合
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SalaryCalcService {

    private final TeacherRuleBindingMapper bindingMapper;
    private final RuleVersionMapper versionMapper;
    private final SalarySnapshotMapper snapshotMapper;
    private final SalaryDetailMapper detailMapper;
    private final SalaryStatementMapper statementMapper;
    private final AdjustmentItemMapper adjustmentMapper;
    private final AuditLogMapper auditLogMapper;

    /**
     * 计算单个打卡记录的工资明细
     * 跳过试听课/补课：schedule_type != NORMAL
     */
    @Transactional
    public SalaryDetail calcSingle(Attendance attendance, Schedule schedule, Teacher teacher, String calcMonth) {
        // 0. 跳过
        if (!"NORMAL".equals(schedule.getScheduleType())) {
            log.debug("跳过非工资课 scheduleId={}, type={}", schedule.getId(), schedule.getScheduleType());
            return null;
        }

        // 1. 匹配生效规则版本
        LocalDate calcDate = schedule.getStartTime().toLocalDate();
        TeacherRuleBinding binding = findEffectiveBinding(teacher.getId(), calcDate);
        if (binding == null) {
            throw new BizException(4001, "教师[" + teacher.getName() + "]在[" + calcDate + "]未绑定生效规则");
        }
        RuleVersion version = versionMapper.selectById(binding.getRuleVersionId());
        if (version == null || version.getStatus() != 2) {
            throw new BizException(4002, "规则版本异常: id=" + binding.getRuleVersionId());
        }

        // 2. 合并参数（默认 + 教师覆盖）
        Map<String, Object> defaultParams = JsonUtil.parseObject(version.getDefaultParams(), Map.class);
        Map<String, Object> overrides = binding.getParamOverrides() != null
                ? JsonUtil.parseObject(binding.getParamOverrides(), Map.class) : new HashMap<>();
        Map<String, Object> finalParams = mergeParams(defaultParams, overrides);

        // 3. 固化快照（计算前先写入）
        SalarySnapshot snapshot = SalarySnapshot.builder()
                .teacherId(teacher.getId())
                .attendanceId(attendance.getId())
                .ruleVersionId(version.getId())
                .snapshotMonth(calcMonth)
                .snapshotTime(LocalDateTime.now())
                .formulaSnapshot(version.getFormula())
                .paramsSnapshot(JsonUtil.toJson(finalParams))
                .attendanceSnapshot(JsonUtil.toJson(attendance))
                .teacherInfoSnapshot(JsonUtil.toJson(Map.of("level", teacher.getLevel(), "employmentType", teacher.getEmploymentType())))
                .scheduleInfoSnapshot(JsonUtil.toJson(schedule))
                .calculationSnapshot("{}")  // 计算后回填
                .build();
        snapshotMapper.insert(snapshot);

        // 4. 提取运行时变量
        BigDecimal hours = BigDecimal.valueOf(attendance.getDurationMinutes())
                .divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);

        int studentCount = attendance.getStudentCount() == null ? 0 : attendance.getStudentCount();
        int leaveCount = attendance.getLeaveCount() == null ? 0 : attendance.getLeaveCount();
        int headcountBase = Math.max(0, studentCount - leaveCount);

        String courseType = schedule.getCourseType();
        String teacherLevel = teacher.getLevel();
        boolean isWeekend = schedule.getStartTime().getDayOfWeek().getValue() >= 6; // Sat=6, Sun=7
        int hour = schedule.getStartTime().getHour();
        boolean isEvening = hour >= 18 && hour <= 20;

        Map<String, Object> trace = new LinkedHashMap<>();

        // 5.1 基础课时费
        BigDecimal baseRate = toBigDecimal(finalParams.get("base_rate"));
        BigDecimal baseAmount = baseRate.multiply(hours).setScale(2, RoundingMode.HALF_UP);
        trace.put("base", Map.of("base_rate", baseRate, "hours", hours, "result", baseAmount));

        // 5.2 人头分段累加
        BigDecimal headcountAmount = calcHeadcountTier(finalParams, headcountBase, trace);

        // 5.3 课程类型系数
        BigDecimal courseCoef = lookupCoef(finalParams, "course_type_coefs", courseType);
        BigDecimal courseBonus = baseAmount.multiply(courseCoef.subtract(BigDecimal.ONE)).setScale(2, RoundingMode.HALF_UP);
        trace.put("course", Map.of("coef", courseCoef, "result", courseBonus));

        // 5.4 教师等级系数
        BigDecimal levelCoef = lookupCoef(finalParams, "teacher_level_coefs", teacherLevel);
        BigDecimal levelBonus = baseAmount.multiply(levelCoef.subtract(BigDecimal.ONE)).setScale(2, RoundingMode.HALF_UP);
        trace.put("level", Map.of("coef", levelCoef, "result", levelBonus));

        // 5.5 时段补贴（取单一最高档，不叠加）
        BigDecimal weekendSubsidy = isWeekend ? toBigDecimal(getNested(finalParams, "time_slot_subsidies", "weekend")) : BigDecimal.ZERO;
        BigDecimal eveningSubsidy = isEvening ? toBigDecimal(getNested(finalParams, "time_slot_subsidies", "evening")) : BigDecimal.ZERO;
        BigDecimal timeSlotSubsidy = weekendSubsidy.max(eveningSubsidy);
        String subsidyType = timeSlotSubsidy.compareTo(BigDecimal.ZERO) == 0 ? "none"
                : weekendSubsidy.compareTo(eveningSubsidy) >= 0 ? "weekend" : "evening";
        trace.put("time_slot", Map.of("subsidy_type", subsidyType, "weekend", weekendSubsidy, "evening", eveningSubsidy, "result", timeSlotSubsidy));

        // 5.6 合计
        BigDecimal detailAmount = baseAmount.add(headcountAmount)
                .add(courseBonus).add(levelBonus).add(timeSlotSubsidy);

        // 6. 更新快照计算轨迹
        snapshot.setCalculationSnapshot(JsonUtil.toJson(trace));
        snapshotMapper.updateById(snapshot);

        // 7. 保存明细
        SalaryDetail detail = SalaryDetail.builder()
                .teacherId(teacher.getId())
                .attendanceId(attendance.getId())
                .scheduleId(schedule.getId())
                .calcMonth(calcMonth)
                .hours(hours.doubleValue())
                .baseAmount(baseAmount)
                .headcountAmount(headcountAmount)
                .courseTypeBonus(courseBonus)
                .levelBonus(levelBonus)
                .timeSlotSubsidy(timeSlotSubsidy)
                .detailAmount(detailAmount.setScale(2, RoundingMode.HALF_UP))
                .ruleVersionId(version.getId())
                .snapshotId(snapshot.getId())
                .build();
        detailMapper.insert(detail);

        log.info("计算完成 teacher={} schedule={} hours={} headcount={} amount={}",
                teacher.getName(), schedule.getId(), hours, headcountBase, detail.getDetailAmount());

        return detail;
    }

    /**
     * 按月批量计算
     * 跨月归属：calc_month = schedule.start_time 所在自然月
     */
    @Transactional
    public Map<String, Object> runMonthlyCalc(String targetMonth, Long operatorId, String operatorName) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM");
        String month = targetMonth != null ? targetMonth : LocalDate.now().format(fmt);

        // 查询已审核通过 + 排课开始时间在当月 + 工资单未锁定的打卡
        LocalDate monthStart = LocalDate.parse(month + "-01");
        LocalDate monthEnd = monthStart.plusMonths(1).minusDays(1);

        List<Attendance> attendances = new ArrayList<>();
        // 注意：这里简化处理，实际可以用 join schedule 查询，MyBatis-Plus 直接查
        // 我们先查所有 audit_status=1 的打卡，然后过滤 schedule 时间
        List<Attendance> allApproved = attendanceMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Attendance>()
                        .eq("audit_status", 1)
        );

        Map<Long, Schedule> scheduleCache = new HashMap<>();
        Map<Long, Teacher> teacherCache = new HashMap<>();
        Map<Long, com.school.salary.entity.ClassInfo> classCache = new HashMap<>();

        List<String> errors = new ArrayList<>();
        Map<String, List<SalaryDetail>> detailsByTeacher = new HashMap<>();

        for (Attendance att : allApproved) {
            try {
                Schedule schedule = scheduleCache.computeIfAbsent(att.getScheduleId(), id -> {
                    Schedule s = new Schedule();
                    s.setId(id);
                    return scheduleMapper.selectById(id);
                });
                if (schedule == null) continue;
                if (schedule.getStartTime().toLocalDate().isBefore(monthStart)) continue;
                if (schedule.getStartTime().toLocalDate().isAfter(monthEnd)) continue;

                // 工资单已锁定的跳过（salary_statement status >= 2）
                boolean locked = detailMapper.selectCount(
                        new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<SalaryDetail>()
                                .eq("attendance_id", att.getId())
                                .inSql("statement_id", "SELECT id FROM salary_statement WHERE status >= 2")
                ) > 0;
                if (locked) continue;

                // 教师
                Teacher teacher = teacherCache.computeIfAbsent(att.getTeacherId(), teacherMapper::selectById);
                if (teacher == null) continue;

                // 调用单条计算
                SalaryDetail detail = calcSingle(att, schedule, teacher, month);
                if (detail == null) continue;

                String key = teacher.getId() + "_" + month;
                detailsByTeacher.computeIfAbsent(key, k -> new ArrayList<>()).add(detail);
            } catch (BizException e) {
                errors.add("打卡[" + att.getId() + "] " + e.getMsg());
                log.warn("计算失败: {}", e.getMsg());
            } catch (Exception e) {
                errors.add("打卡[" + att.getId() + "] 异常: " + e.getMessage());
                log.error("计算异常", e);
            }
        }

        // 聚合工资单
        for (Map.Entry<String, List<SalaryDetail>> entry : detailsByTeacher.entrySet()) {
            String[] parts = entry.getKey().split("_");
            Long teacherId = Long.parseLong(parts[0]);
            String m = parts[1];
            List<SalaryDetail> details = entry.getValue();

            // 查教师获取 campus_id
            Teacher t = teacherCache.computeIfAbsent(teacherId, teacherMapper::selectById);
            if (t == null) continue;

            // 先把所有明细挂到 statement_id（先查或创建）
            SalaryStatement statement = statementMapper.selectOne(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<SalaryStatement>()
                            .eq("teacher_id", teacherId)
                            .eq("month", m)
            );
            if (statement == null) {
                statement = SalaryStatement.builder()
                        .teacherId(teacherId)
                        .campusId(t.getCampusId())
                        .month(m)
                        .grossAmount(BigDecimal.ZERO)
                        .adjustmentAmount(BigDecimal.ZERO)
                        .netAmount(BigDecimal.ZERO)
                        .status(0)
                        .build();
                statementMapper.insert(statement);
            }

            // 重算前清空旧明细（未锁定）
            detailMapper.delete(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<SalaryDetail>()
                            .eq("statement_id", statement.getId())
            );

            BigDecimal gross = BigDecimal.ZERO;
            for (SalaryDetail d : details) {
                d.setStatementId(statement.getId());
                detailMapper.insert(d);
                gross = gross.add(d.getDetailAmount());
            }

            // 查调整项
            BigDecimal adjustment = adjustmentMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<AdjustmentItem>()
                            .eq("statement_id", statement.getId())
                            .eq("status", 1)
            ).stream().map(AdjustmentItem::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

            statement.setGrossAmount(gross);
            statement.setAdjustmentAmount(adjustment);
            statement.setNetAmount(gross.add(adjustment));
            statement.setStatus(0); // 草稿
            statementMapper.updateById(statement);
        }

        // 审计日志
        auditLogMapper.insert(AuditLog.builder()
                .operatorId(operatorId)
                .operatorName(operatorName)
                .action("CALC")
                .targetType("SalaryStatement")
                .targetName("月度计算:" + month)
                .remark("明细总数=" + detailsByTeacher.values().stream().mapToInt(List::size).sum()
                        + ", 教师数=" + detailsByTeacher.size()
                        + ", 异常数=" + errors.size())
                .createdAt(LocalDateTime.now())
                .build());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("month", month);
        result.put("detailsCount", detailsByTeacher.values().stream().mapToInt(List::size).sum());
        result.put("teacherCount", detailsByTeacher.size());
        result.put("errors", errors);
        return result;
    }

    // ==================== 辅助方法 ====================

    private TeacherRuleBinding findEffectiveBinding(Long teacherId, LocalDate calcDate) {
        List<TeacherRuleBinding> bindings = bindingMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<TeacherRuleBinding>()
                        .eq("teacher_id", teacherId)
                        .le("effective_from", calcDate)
                        .and(w -> w.isNull("effective_to").or().ge("effective_to", calcDate))
                        .orderByDesc("priority")
                        .orderByDesc("effective_from")
        );
        return bindings.isEmpty() ? null : bindings.get(0);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> mergeParams(Map<String, Object> defaults, Map<String, Object> overrides) {
        Map<String, Object> result = new LinkedHashMap<>(defaults);
        if (overrides != null) {
            for (Map.Entry<String, Object> e : overrides.entrySet()) {
                if (e.getValue() != null) {
                    result.put(e.getKey(), e.getValue());
                }
            }
        }
        return result;
    }

    /**
     * 分段累加人头费
     * tiers = [ {base_count: 15, extra_per_person: 5}, {base_count: 25, extra_per_person: 8} ]
     * headcount_base = 实到 - 请假
     */
    @SuppressWarnings("unchecked")
    private BigDecimal calcHeadcountTier(Map<String, Object> params, int headcountBase, Map<String, Object> trace) {
        BigDecimal total = BigDecimal.ZERO;
        List<Map<String, Object>> segments = new ArrayList<>();

        Object tiersObj = params.get("headcount_tiers");
        if (tiersObj == null || headcountBase <= 0) {
            trace.put("headcount", Map.of("base", headcountBase, "result", total, "segments", segments));
            return total;
        }

        List<Map<String, Object>> tiers;
        if (tiersObj instanceof List) {
            tiers = (List<Map<String, Object>>) tiersObj;
        } else {
            tiers = JsonUtil.parseArray(JsonUtil.toJson(tiersObj), Map.class);
        }

        // 按 base_count 升序
        tiers.sort(Comparator.comparingInt(t -> ((Number) t.get("base_count")).intValue()));

        for (Map<String, Object> tier : tiers) {
            int threshold = ((Number) tier.get("base_count")).intValue();
            BigDecimal rate = toBigDecimal(tier.get("extra_per_person"));
            int exceed = headcountBase - threshold;
            if (exceed > 0) {
                BigDecimal segAmount = rate.multiply(BigDecimal.valueOf(exceed));
                total = total.add(segAmount);
                segments.add(Map.of(
                        "threshold", threshold,
                        "rate", rate,
                        "exceed", exceed,
                        "amount", segAmount
                ));
            }
        }

        trace.put("headcount", Map.of("base", headcountBase, "result", total, "segments", segments));
        return total.setScale(2, RoundingMode.HALF_UP);
    }

    @SuppressWarnings("unchecked")
    private BigDecimal lookupCoef(Map<String, Object> params, String mapKey, String lookupKey) {
        Object obj = params.get(mapKey);
        if (obj instanceof Map) {
            Object v = ((Map<String, Object>) obj).get(lookupKey);
            if (v != null) return toBigDecimal(v);
        }
        return BigDecimal.ONE;
    }

    @SuppressWarnings("unchecked")
    private Object getNested(Map<String, Object> params, String outer, String inner) {
        Object obj = params.get(outer);
        if (obj instanceof Map) {
            return ((Map<String, Object>) obj).get(inner);
        }
        return null;
    }

    private BigDecimal toBigDecimal(Object v) {
        if (v == null) return BigDecimal.ZERO;
        if (v instanceof BigDecimal) return (BigDecimal) v;
        if (v instanceof Number) return BigDecimal.valueOf(((Number) v).doubleValue());
        try { return new BigDecimal(v.toString()); } catch (Exception e) { return BigDecimal.ZERO; }
    }
}
