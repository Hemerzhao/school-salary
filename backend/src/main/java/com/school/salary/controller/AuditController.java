package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.school.salary.common.Result;
import com.school.salary.entity.AuditLog;
import com.school.salary.repository.AuditLogMapper;
import com.school.salary.util.DateParseUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * 审计日志查询
 */
@Slf4j
@RestController
@RequestMapping("/api/audit")
@RequiredArgsConstructor
public class AuditController {

    private final AuditLogMapper auditLogMapper;

    /**
     * 审计日志分页查询
     */
    @GetMapping("/log/list")
    public Result<Page<AuditLog>> list(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) String targetType,
            @RequestParam(required = false) Long operatorId,
            @RequestParam(required = false) String startFrom,
            @RequestParam(required = false) String startTo,
            @RequestParam(required = false) String action) {
        QueryWrapper<AuditLog> wrapper = new QueryWrapper<>();
        if (targetType != null && !targetType.isBlank()) {
            wrapper.eq("target_type", targetType);
        }
        if (operatorId != null) {
            wrapper.eq("operator_id", operatorId);
        }
        if (action != null && !action.isBlank()) {
            wrapper.eq("action", action);
        }
        if (startFrom != null && !startFrom.isBlank()) {
            wrapper.ge("created_at", DateParseUtil.parseFlexible(startFrom));
        }
        if (startTo != null && !startTo.isBlank()) {
            wrapper.le("created_at", DateParseUtil.parseFlexible(startTo));
        }
        wrapper.orderByDesc("created_at");
        return Result.ok(auditLogMapper.selectPage(new Page<>(current, size), wrapper));
    }
}
