package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.*;
import com.school.salary.repository.*;
import com.school.salary.service.SalaryCalcService;
import io.jsonwebtoken.Claims;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

/**
 * 工资计算 & 工资单 & 调整项
 */
@Slf4j
@RestController
@RequestMapping("/api/salary")
@RequiredArgsConstructor
public class SalaryController {

    private final SalaryCalcService salaryCalcService;
    private final SalaryStatementMapper statementMapper;
    private final SalaryDetailMapper detailMapper;
    private final SalarySnapshotMapper snapshotMapper;
    private final AdjustmentItemMapper adjustmentMapper;
    private final AuditLogMapper auditLogMapper;
    private final TeacherMapper teacherMapper;

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expire-hours}")
    private long jwtExpireHours;

    private com.school.salary.util.JwtUtil jwtUtil;

    @PostConstruct
    public void init() {
        this.jwtUtil = new com.school.salary.util.JwtUtil(jwtSecret, jwtExpireHours * 3600);
    }

    // ==================== 月度计算 ====================

    /**
     * 触发月度计算
     */
    @PostMapping("/calc/month")
    public Result<Map<String, Object>> calcMonth(
            @RequestParam String month,
            @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);

        Map<String, Object> result = salaryCalcService.runMonthlyCalc(month, operatorId, operatorName);
        return Result.ok(result);
    }

    // ==================== 工资单 ====================

    @GetMapping("/statement/list")
    public Result<Page<SalaryStatement>> statementPage(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Long teacherId,
            @RequestParam(required = false) Long campusId,
            @RequestParam(required = false) String month,
            @RequestParam(required = false) Integer status) {
        QueryWrapper<SalaryStatement> wrapper = new QueryWrapper<>();
        if (teacherId != null) {
            wrapper.eq("teacher_id", teacherId);
        }
        if (campusId != null) {
            wrapper.eq("campus_id", campusId);
        }
        if (month != null && !month.isBlank()) {
            wrapper.eq("month", month);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("month").orderByDesc("teacher_id");
        return Result.ok(statementMapper.selectPage(new Page<>(current, size), wrapper));
    }

    @GetMapping("/statement/{id}")
    public Result<Map<String, Object>> statementDetail(@PathVariable Long id) {
        SalaryStatement statement = statementMapper.selectById(id);
        if (statement == null) {
            throw new BizException("工资单不存在");
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("statement", statement);

        // 关联明细
        List<SalaryDetail> details = detailMapper.selectList(
                new QueryWrapper<SalaryDetail>().eq("statement_id", id).orderByAsc("id"));
        result.put("details", details);

        // 关联快照
        if (!details.isEmpty()) {
            List<Long> snapshotIds = new ArrayList<>();
            for (SalaryDetail d : details) {
                if (d.getSnapshotId() != null) {
                    snapshotIds.add(d.getSnapshotId());
                }
            }
            if (!snapshotIds.isEmpty()) {
                result.put("snapshots", snapshotMapper.selectBatchIds(snapshotIds));
            }
        }

        // 关联调整项
        List<AdjustmentItem> adjustments = adjustmentMapper.selectList(
                new QueryWrapper<AdjustmentItem>().eq("statement_id", id).orderByAsc("id"));
        result.put("adjustments", adjustments);

        return Result.ok(result);
    }

    /**
     * 确认工资单 status 0→1
     */
    @PostMapping("/statement/{id}/confirm")
    public Result<SalaryStatement> confirm(@PathVariable Long id,
                                             @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);

        SalaryStatement statement = statementMapper.selectById(id);
        if (statement == null) {
            throw new BizException("工资单不存在");
        }
        if (statement.getStatus() == null || statement.getStatus() != 0) {
            throw new BizException("仅草稿状态可以确认");
        }
        statement.setStatus(1);
        statement.setUpdatedAt(LocalDateTime.now());
        statementMapper.updateById(statement);

        logAudit("CONFIRM", "SalaryStatement", id, statement.getMonth(), operatorId, operatorName);
        return Result.ok(statementMapper.selectById(id));
    }

    /**
     * 锁定工资单 status 1→2
     */
    @PostMapping("/statement/{id}/lock")
    public Result<SalaryStatement> lock(@PathVariable Long id,
                                          @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);

        SalaryStatement statement = statementMapper.selectById(id);
        if (statement == null) {
            throw new BizException("工资单不存在");
        }
        if (statement.getStatus() == null || statement.getStatus() != 1) {
            throw new BizException("仅已确认状态可以锁定");
        }
        statement.setStatus(2);
        statement.setLockedAt(LocalDateTime.now());
        statement.setLockedBy(operatorId);
        statement.setUpdatedAt(LocalDateTime.now());
        statementMapper.updateById(statement);

        logAudit("LOCK", "SalaryStatement", id, statement.getMonth(), operatorId, operatorName);
        return Result.ok(statementMapper.selectById(id));
    }

    /**
     * 解锁工资单 - 仅超管
     */
    @PostMapping("/statement/{id}/unlock")
    public Result<SalaryStatement> unlock(@PathVariable Long id,
                                           @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);
        String role = parseRole(authHeader);

        // 仅超管
        if (!"SUPER_ADMIN".equals(role)) {
            throw new BizException(403, "仅超管可以解锁工资单");
        }

        SalaryStatement statement = statementMapper.selectById(id);
        if (statement == null) {
            throw new BizException("工资单不存在");
        }
        if (statement.getStatus() == null || statement.getStatus() != 2) {
            throw new BizException("仅已锁定状态可以解锁");
        }
        statement.setStatus(1);
        statement.setLockedAt(null);
        statement.setLockedBy(null);
        statement.setUpdatedAt(LocalDateTime.now());
        statementMapper.updateById(statement);

        logAudit("UNLOCK", "SalaryStatement", id, statement.getMonth(), operatorId, operatorName);
        return Result.ok(statementMapper.selectById(id));
    }

    /**
     * 标记已发放 status 2→3
     */
    @PostMapping("/statement/{id}/mark-paid")
    public Result<SalaryStatement> markPaid(@PathVariable Long id,
                                              @RequestBody(required = false) Map<String, String> body,
                                              @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);

        SalaryStatement statement = statementMapper.selectById(id);
        if (statement == null) {
            throw new BizException("工资单不存在");
        }
        if (statement.getStatus() == null || statement.getStatus() != 2) {
            throw new BizException("仅已锁定状态可以标记发放");
        }
        statement.setStatus(3);
        statement.setPaidAt(LocalDateTime.now());
        if (body != null && body.get("paid_voucher") != null) {
            statement.setPaidVoucher(body.get("paid_voucher"));
        }
        statement.setUpdatedAt(LocalDateTime.now());
        statementMapper.updateById(statement);

        logAudit("MARK_PAID", "SalaryStatement", id, statement.getMonth(), operatorId, operatorName);
        return Result.ok(statementMapper.selectById(id));
    }

    // ==================== 调整项 ====================

    /**
     * 创建调整项
     */
    @PostMapping("/adjustment")
    public Result<AdjustmentItem> createAdjustment(@RequestBody AdjustmentItem adjustment,
                                                     @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);

        if (adjustment.getTeacherId() == null || adjustment.getMonth() == null
                || adjustment.getAdjustType() == null || adjustment.getAmount() == null
                || adjustment.getReason() == null) {
            throw new BizException("teacher_id, month, adjust_type, amount, reason 必填");
        }

        // 自动找或建 statement 关联
        SalaryStatement statement = statementMapper.selectOne(
                new QueryWrapper<SalaryStatement>()
                        .eq("teacher_id", adjustment.getTeacherId())
                        .eq("month", adjustment.getMonth())
        );
        if (statement == null) {
            Teacher teacher = teacherMapper.selectById(adjustment.getTeacherId());
            if (teacher == null) {
                throw new BizException("教师不存在");
            }
            statement = SalaryStatement.builder()
                    .teacherId(adjustment.getTeacherId())
                    .campusId(teacher.getCampusId())
                    .month(adjustment.getMonth())
                    .grossAmount(BigDecimal.ZERO)
                    .adjustmentAmount(BigDecimal.ZERO)
                    .netAmount(BigDecimal.ZERO)
                    .status(0)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
            statementMapper.insert(statement);
        }

        adjustment.setStatementId(statement.getId());
        adjustment.setStatus(0); // 草稿
        adjustment.setApplyBy(operatorId);
        adjustment.setApplyAt(LocalDateTime.now());
        adjustmentMapper.insert(adjustment);
        return Result.ok(adjustment);
    }

    /**
     * 确认调整项 status 0→1，重算 statement.net_amount
     */
    @PostMapping("/adjustment/{id}/confirm")
    public Result<AdjustmentItem> confirmAdjustment(@PathVariable Long id,
                                                     @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);

        AdjustmentItem item = adjustmentMapper.selectById(id);
        if (item == null) {
            throw new BizException("调整项不存在");
        }
        if (item.getStatus() == null || item.getStatus() != 0) {
            throw new BizException("仅草稿状态可以确认");
        }

        item.setStatus(1);
        adjustmentMapper.updateById(item);

        // 重算 statement.net_amount
        SalaryStatement statement = statementMapper.selectById(item.getStatementId());
        if (statement != null) {
            BigDecimal adjustmentTotal = adjustmentMapper.selectList(
                    new QueryWrapper<AdjustmentItem>()
                            .eq("statement_id", statement.getId())
                            .eq("status", 1)
            ).stream().map(AdjustmentItem::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

            statement.setAdjustmentAmount(adjustmentTotal);
            statement.setNetAmount(statement.getGrossAmount() == null ? BigDecimal.ZERO
                    : statement.getGrossAmount().add(adjustmentTotal));
            statement.setUpdatedAt(LocalDateTime.now());
            statementMapper.updateById(statement);

            logAudit("ADJUST_CONFIRM", "AdjustmentItem", id, item.getReason(), operatorId, operatorName);
        }

        return Result.ok(adjustmentMapper.selectById(id));
    }

    // ==================== 明细 & 快照 ====================

    @GetMapping("/detail/list")
    public Result<List<SalaryDetail>> detailList(@RequestParam Long statementId) {
        List<SalaryDetail> details = detailMapper.selectList(
                new QueryWrapper<SalaryDetail>()
                        .eq("statement_id", statementId)
                        .orderByAsc("id"));
        return Result.ok(details);
    }

    @GetMapping("/snapshot/{id}")
    public Result<SalarySnapshot> snapshotDetail(@PathVariable Long id) {
        SalarySnapshot snapshot = snapshotMapper.selectById(id);
        if (snapshot == null) {
            throw new BizException("快照不存在");
        }
        return Result.ok(snapshot);
    }

    // ==================== 辅助 ====================

    private void logAudit(String action, String targetType, Long targetId, String targetName,
                           Long operatorId, String operatorName) {
        auditLogMapper.insert(AuditLog.builder()
                .operatorId(operatorId)
                .operatorName(operatorName)
                .action(action)
                .targetType(targetType)
                .targetId(targetId)
                .targetName(targetName)
                .createdAt(LocalDateTime.now())
                .build());
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

    private String parseRole(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new BizException(401, "缺少 Authorization");
        }
        try {
            Claims claims = jwtUtil.parseClaims(authHeader.substring("Bearer ".length()));
            return claims.get("role", String.class);
        } catch (Exception e) {
            throw new BizException(401, "登录已过期，请重新登录");
        }
    }
}
