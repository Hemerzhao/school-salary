package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.*;
import com.school.salary.repository.*;
import com.school.salary.util.JsonUtil;
import io.jsonwebtoken.Claims;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.*;

/**
 * 规则模板 & 版本 & 绑定 & 预览 & 校验
 */
@Slf4j
@RestController
@RequestMapping("/api/rule")
@RequiredArgsConstructor
public class RuleController {

    private final RuleTemplateMapper templateMapper;
    private final RuleVersionMapper versionMapper;
    private final TeacherRuleBindingMapper bindingMapper;
    private final SalaryStatementMapper statementMapper;
    private final TeacherMapper teacherMapper;
    private final AttendanceMapper attendanceMapper;
    private final AuditLogMapper auditLogMapper;

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expire-hours}")
    private long jwtExpireHours;

    private com.school.salary.util.JwtUtil jwtUtil;

    @PostConstruct
    public void init() {
        this.jwtUtil = new com.school.salary.util.JwtUtil(jwtSecret, jwtExpireHours * 3600);
    }

    // ==================== 模板 CRUD ====================

    @PostMapping("/template")
    public Result<RuleTemplate> createTemplate(@RequestBody RuleTemplate template,
                                                 @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        template.setCreatedBy(operatorId);
        template.setCreatedAt(LocalDateTime.now());
        template.setUpdatedAt(LocalDateTime.now());
        if (template.getStatus() == null) {
            template.setStatus(1);
        }
        templateMapper.insert(template);
        return Result.ok(template);
    }

    @PutMapping("/template/{id}")
    public Result<RuleTemplate> updateTemplate(@PathVariable Long id,
                                                @RequestBody RuleTemplate template) {
        RuleTemplate existing = templateMapper.selectById(id);
        if (existing == null) {
            throw new BizException("模板不存在");
        }
        template.setId(id);
        template.setUpdatedAt(LocalDateTime.now());
        templateMapper.updateById(template);
        return Result.ok(templateMapper.selectById(id));
    }

    @DeleteMapping("/template/{id}")
    public Result<Void> deleteTemplate(@PathVariable Long id) {
        RuleTemplate existing = templateMapper.selectById(id);
        if (existing == null) {
            throw new BizException("模板不存在");
        }
        // 检查是否有已发布的版本
        Long publishedCount = versionMapper.selectCount(
                new QueryWrapper<RuleVersion>().eq("template_id", id).in("status", 2, 3));
        if (publishedCount != null && publishedCount > 0) {
            throw new BizException("模板下有已发布/已停用的版本，不能删除");
        }
        versionMapper.delete(new QueryWrapper<RuleVersion>().eq("template_id", id));
        templateMapper.deleteById(id);
        return Result.ok();
    }

    @GetMapping("/template/list")
    public Result<List<RuleTemplate>> listTemplate(
            @RequestParam(required = false) Integer status) {
        QueryWrapper<RuleTemplate> wrapper = new QueryWrapper<>();
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("id");
        return Result.ok(templateMapper.selectList(wrapper));
    }

    // ==================== 版本管理 ====================

    /**
     * 基于模板创建新版本（默认草稿 status=0）
     */
    @PostMapping("/template/{templateId}/version")
    public Result<RuleVersion> createVersion(@PathVariable Long templateId,
                                               @RequestBody RuleVersion version,
                                               @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);

        RuleTemplate template = templateMapper.selectById(templateId);
        if (template == null) {
            throw new BizException("模板不存在");
        }

        version.setTemplateId(templateId);
        version.setStatus(0); // 草稿
        version.setCreatedBy(operatorId);
        version.setCreatedAt(LocalDateTime.now());
        versionMapper.insert(version);
        return Result.ok(version);
    }

    /**
     * 编辑草稿版本
     */
    @PutMapping("/version/{id}")
    public Result<RuleVersion> updateVersion(@PathVariable Long id,
                                               @RequestBody RuleVersion version) {
        RuleVersion existing = versionMapper.selectById(id);
        if (existing == null) {
            throw new BizException("规则版本不存在");
        }
        if (existing.getStatus() != null && existing.getStatus() != 0) {
            throw new BizException("仅草稿状态可以编辑");
        }
        version.setId(id);
        versionMapper.updateById(version);
        return Result.ok(versionMapper.selectById(id));
    }

    /**
     * 发布版本
     */
    @PostMapping("/version/{id}/publish")
    public Result<RuleVersion> publishVersion(@PathVariable Long id,
                                                @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);

        RuleVersion version = versionMapper.selectById(id);
        if (version == null) {
            throw new BizException("规则版本不存在");
        }
        if (version.getStatus() == null || version.getStatus() != 0) {
            throw new BizException("仅草稿状态可以发布");
        }
        if (version.getChangeLog() == null || version.getChangeLog().isBlank()) {
            throw new BizException("change_log 必填");
        }

        // 校验：effective_from > 所有已锁定工资单所属月起始日
        List<SalaryStatement> lockedStatements = statementMapper.selectList(
                new QueryWrapper<SalaryStatement>().ge("status", 2));
        for (SalaryStatement st : lockedStatements) {
            LocalDate monthStart = YearMonth.parse(st.getMonth()).atDay(1);
            if (version.getEffectiveFrom() != null
                    && !version.getEffectiveFrom().isAfter(monthStart)) {
                throw new BizException("effective_from 必须晚于所有已锁定工资单的月份起始日（最早锁定月: " + st.getMonth() + "）");
            }
        }

        version.setStatus(2);
        versionMapper.updateById(version);

        auditLogMapper.insert(AuditLog.builder()
                .operatorId(operatorId)
                .operatorName(operatorName)
                .action("PUBLISH")
                .targetType("RuleVersion")
                .targetId(id)
                .targetName(version.getVersionNo())
                .remark(version.getChangeLog())
                .createdAt(LocalDateTime.now())
                .build());

        return Result.ok(versionMapper.selectById(id));
    }

    /**
     * 停用版本
     */
    @PostMapping("/version/{id}/disable")
    public Result<RuleVersion> disableVersion(@PathVariable Long id) {
        RuleVersion version = versionMapper.selectById(id);
        if (version == null) {
            throw new BizException("规则版本不存在");
        }
        if (version.getStatus() != null && version.getStatus() != 2) {
            throw new BizException("仅已发布状态可以停用");
        }
        version.setStatus(3);
        versionMapper.updateById(version);
        return Result.ok(versionMapper.selectById(id));
    }

    // ==================== 绑定 ====================

    @PostMapping("/binding")
    public Result<TeacherRuleBinding> createBinding(@RequestBody TeacherRuleBinding binding,
                                                    @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);

        if (binding.getTeacherId() == null || binding.getRuleVersionId() == null
                || binding.getEffectiveFrom() == null) {
            throw new BizException("teacher_id, rule_version_id, effective_from 必填");
        }
        RuleVersion version = versionMapper.selectById(binding.getRuleVersionId());
        if (version == null || version.getStatus() == null || version.getStatus() != 2) {
            throw new BizException("绑定的规则版本必须已发布");
        }

        binding.setCreatedBy(operatorId);
        binding.setCreatedAt(LocalDateTime.now());
        bindingMapper.insert(binding);
        return Result.ok(binding);
    }

    @PutMapping("/binding/{id}")
    public Result<TeacherRuleBinding> updateBinding(@PathVariable Long id,
                                                     @RequestBody TeacherRuleBinding binding) {
        TeacherRuleBinding existing = bindingMapper.selectById(id);
        if (existing == null) {
            throw new BizException("绑定不存在");
        }
        binding.setId(id);
        bindingMapper.updateById(binding);
        return Result.ok(bindingMapper.selectById(id));
    }

    @DeleteMapping("/binding/{id}")
    public Result<Void> deleteBinding(@PathVariable Long id) {
        TeacherRuleBinding existing = bindingMapper.selectById(id);
        if (existing == null) {
            throw new BizException("绑定不存在");
        }
        bindingMapper.deleteById(id);
        return Result.ok();
    }

    // ==================== 预览 ====================

    /**
     * 预览指定教师在指定日期的生效规则 + 样例打卡计算
     */
    @GetMapping("/preview")
    public Result<Map<String, Object>> preview(
            @RequestParam Long teacherId,
            @RequestParam String date) {
        LocalDate targetDate = LocalDate.parse(date);
        Teacher teacher = teacherMapper.selectById(teacherId);
        if (teacher == null) {
            throw new BizException("教师不存在");
        }

        // 匹配绑定
        List<TeacherRuleBinding> bindings = bindingMapper.selectList(
                new QueryWrapper<TeacherRuleBinding>()
                        .eq("teacher_id", teacherId)
                        .le("effective_from", targetDate)
                        .and(w -> w.isNull("effective_to").or().ge("effective_to", targetDate))
                        .orderByDesc("priority")
                        .orderByDesc("effective_from")
        );

        Map<String, Object> result = new LinkedHashMap<>();
        if (bindings.isEmpty()) {
            result.put("binding", null);
            result.put("warning", "未找到匹配的规则绑定");
            return Result.ok(result);
        }

        TeacherRuleBinding binding = bindings.get(0);
        RuleVersion version = versionMapper.selectById(binding.getRuleVersionId());
        if (version == null || version.getStatus() == null || version.getStatus() != 2) {
            result.put("binding", binding);
            result.put("previewError", "绑定的规则版本未发布");
            return Result.ok(result);
        }

        // 合并参数
        Map<String, Object> defaultParams = JsonUtil.parseObject(version.getDefaultParams(), Map.class);
        Map<String, Object> overrides = binding.getParamOverrides() != null
                ? JsonUtil.parseObject(binding.getParamOverrides(), Map.class) : new HashMap<>();
        Map<String, Object> finalParams = new LinkedHashMap<>(defaultParams);
        for (Map.Entry<String, Object> e : overrides.entrySet()) {
            if (e.getValue() != null) {
                finalParams.put(e.getKey(), e.getValue());
            }
        }

        result.put("binding", binding);
        result.put("version", version);
        result.put("finalParams", finalParams);
        result.put("formula", version.getFormula());

        // 异常列表
        List<String> warnings = new ArrayList<>();
        if (!overrides.isEmpty()) {
            Set<String> defaultKeys = defaultParams.keySet();
            for (String k : overrides.keySet()) {
                if (!defaultKeys.contains(k)) {
                    warnings.add("覆盖参数中存在模板未定义的 key: " + k);
                }
            }
        }
        result.put("warnings", warnings);

        return Result.ok(result);
    }

    // ==================== 异常校验 ====================

    /**
     * 扫描所有教师，返回规则配置异常
     */
    @GetMapping("/validate")
    public Result<List<Map<String, Object>>> validate(@RequestParam String month) {
        LocalDate monthStart = YearMonth.parse(month).atDay(1);
        LocalDate monthEnd = YearMonth.parse(month).atEndOfMonth();

        List<Teacher> teachers = teacherMapper.selectList(null);
        List<Map<String, Object>> errors = new ArrayList<>();

        for (Teacher t : teachers) {
            // 1. 未绑定规则
            List<TeacherRuleBinding> bindings = bindingMapper.selectList(
                    new QueryWrapper<TeacherRuleBinding>()
                            .eq("teacher_id", t.getId())
                            .le("effective_from", monthEnd)
                            .and(w -> w.isNull("effective_to").or().ge("effective_to", monthStart))
            );
            if (bindings.isEmpty()) {
                Map<String, Object> err = new LinkedHashMap<>();
                err.put("teacherId", t.getId());
                err.put("teacherName", t.getName());
                err.put("type", "未绑定规则");
                err.put("message", "在 " + month + " 期间无生效绑定");
                errors.add(err);
                continue;
            }

            // 2. 绑定区间重叠
            if (bindings.size() > 1) {
                // 检查是否有优先级相同且区间重叠
                for (int i = 0; i < bindings.size(); i++) {
                    for (int j = i + 1; j < bindings.size(); j++) {
                        TeacherRuleBinding a = bindings.get(i);
                        TeacherRuleBinding b = bindings.get(j);
                        if (Objects.equals(a.getPriority(), b.getPriority())
                                && dateOverlap(a.getEffectiveFrom(), a.getEffectiveTo(),
                                b.getEffectiveFrom(), b.getEffectiveTo())) {
                            Map<String, Object> err = new LinkedHashMap<>();
                            err.put("teacherId", t.getId());
                            err.put("teacherName", t.getName());
                            err.put("type", "绑定区间重叠");
                            err.put("message", "绑定[" + a.getId() + "]和[" + b.getId() + "]区间重叠");
                            errors.add(err);
                        }
                    }
                }
            }

            // 3. 公式解析失败（版本未发布）
            for (TeacherRuleBinding b : bindings) {
                RuleVersion v = versionMapper.selectById(b.getRuleVersionId());
                if (v == null || v.getStatus() == null || v.getStatus() != 2) {
                    Map<String, Object> err = new LinkedHashMap<>();
                    err.put("teacherId", t.getId());
                    err.put("teacherName", t.getName());
                    err.put("type", "公式解析失败");
                    err.put("message", "绑定[" + b.getId() + "]关联的规则版本[" + b.getRuleVersionId() + "]未发布");
                    errors.add(err);
                }
            }
        }

        return Result.ok(errors);
    }

    private boolean dateOverlap(LocalDate from1, LocalDate to1, LocalDate from2, LocalDate to2) {
        LocalDate end1 = to1 == null ? LocalDate.MAX : to1;
        LocalDate end2 = to2 == null ? LocalDate.MAX : to2;
        return !from1.isAfter(end2) && !from2.isAfter(end1);
    }

    private Long parseUserId(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new BizException(401, "缺少 Authorization");
        }
        try {
            Claims claims = jwtUtil.parseClaims(authHeader.substring("Bearer ".length()));
            return ((Number) claims.get("userId")).longValue();
        } catch (Exception e) {
            throw new BizException(401, "登录已过期，请重新登录");
        }
    }

    private String parseUsername(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new BizException(401, "缺少 Authorization");
        }
        try {
            Claims claims = jwtUtil.parseClaims(authHeader.substring("Bearer ".length()));
            return claims.get("username", String.class);
        } catch (Exception e) {
            throw new BizException(401, "登录已过期，请重新登录");
        }
    }
}
