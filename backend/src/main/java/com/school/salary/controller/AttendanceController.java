package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.AuditLog;
import com.school.salary.entity.Attendance;
import com.school.salary.entity.Schedule;
import com.school.salary.repository.AttendanceMapper;
import com.school.salary.repository.AuditLogMapper;
import com.school.salary.repository.ScheduleMapper;
import com.school.salary.util.DateParseUtil;
import io.jsonwebtoken.Claims;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 打卡管理
 */
@Slf4j
@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceMapper attendanceMapper;
    private final ScheduleMapper scheduleMapper;
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

    /**
     * 开始打卡
     */
    @PostMapping("/start/{scheduleId}")
    public Result<Attendance> start(@PathVariable Long scheduleId,
                                     @RequestHeader("Authorization") String authHeader) {
        Long userId = parseUserId(authHeader);
        String role = parseRole(authHeader);

        Schedule schedule = scheduleMapper.selectById(scheduleId);
        if (schedule == null) {
            throw new BizException("排课不存在");
        }
        if (schedule.getStatus() != null && schedule.getStatus() == 4) {
            throw new BizException("排课已取消，不能打卡");
        }

        // 校验是否已有打卡
        Attendance existing = attendanceMapper.selectOne(
                new QueryWrapper<Attendance>().eq("schedule_id", scheduleId).last("LIMIT 1"));
        if (existing != null) {
            throw new BizException("该排课已存在打卡记录");
        }

        // 对于教师用户，校验是自己的排课
        if ("TEACHER".equals(role) && schedule.getTeacherId() != null
                && !schedule.getTeacherId().equals(userId)) {
            throw new BizException("无权打卡他人的排课");
        }

        Attendance attendance = Attendance.builder()
                .scheduleId(scheduleId)
                .teacherId(schedule.getTeacherId())
                .campusId(schedule.getCampusId())
                .actualStartTime(LocalDateTime.now())
                .auditStatus(0)
                .isMakeup(0)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        attendanceMapper.insert(attendance);
        return Result.ok(attendance);
    }

    /**
     * 结束打卡
     */
    @PostMapping("/end/{scheduleId}")
    public Result<Attendance> end(@PathVariable Long scheduleId,
                                  @RequestBody Map<String, Object> body) {
        Attendance attendance = attendanceMapper.selectOne(
                new QueryWrapper<Attendance>().eq("schedule_id", scheduleId).last("LIMIT 1"));
        if (attendance == null) {
            throw new BizException("请先开始打卡");
        }
        if (attendance.getActualStartTime() == null) {
            throw new BizException("打卡未开始");
        }

        Integer studentCount = (Integer) body.get("student_count");
        Integer leaveCount = (Integer) body.get("leave_count");
        Integer durationMinutes = (Integer) body.get("duration_minutes");
        String exceptionNote = (String) body.get("exception_note");

        if (studentCount == null || leaveCount == null || durationMinutes == null) {
            throw new BizException("student_count, leave_count, duration_minutes 均为必填");
        }

        attendance.setActualEndTime(LocalDateTime.now());
        attendance.setDurationMinutes(durationMinutes);
        attendance.setStudentCount(studentCount);
        attendance.setLeaveCount(leaveCount);
        attendance.setExceptionNote(exceptionNote);
        attendance.setUpdatedAt(LocalDateTime.now());
        attendanceMapper.updateById(attendance);
        return Result.ok(attendanceMapper.selectById(attendance.getId()));
    }

    /**
     * 当前教师的打卡列表
     */
    @GetMapping("/my")
    public Result<List<Attendance>> my(@RequestHeader("Authorization") String authHeader) {
        Long userId = parseUserId(authHeader);
        QueryWrapper<Attendance> wrapper = new QueryWrapper<>();
        // 教师角色：按 teacher_id 查
        wrapper.eq("teacher_id", userId);
        wrapper.orderByDesc("actual_start_time");
        return Result.ok(attendanceMapper.selectList(wrapper));
    }

    /**
     * 管理员分页查询
     */
    @GetMapping("/list")
    public Result<Page<Attendance>> list(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Long teacherId,
            @RequestParam(required = false) Integer auditStatus,
            @RequestParam(required = false) String startFrom,
            @RequestParam(required = false) String startTo) {
        QueryWrapper<Attendance> wrapper = new QueryWrapper<>();
        if (teacherId != null) {
            wrapper.eq("teacher_id", teacherId);
        }
        if (auditStatus != null) {
            wrapper.eq("audit_status", auditStatus);
        }
        if (startFrom != null && !startFrom.isBlank()) {
            wrapper.ge("actual_start_time", DateParseUtil.parseFlexible(startFrom));
        }
        if (startTo != null && !startTo.isBlank()) {
            wrapper.le("actual_start_time", DateParseUtil.parseFlexible(startTo));
        }
        wrapper.orderByDesc("actual_start_time");
        return Result.ok(attendanceMapper.selectPage(new Page<>(current, size), wrapper));
    }

    /**
     * 审核打卡
     */
    @PostMapping("/audit/{id}")
    public Result<Attendance> audit(@PathVariable Long id,
                                    @RequestBody Map<String, String> body,
                                    @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseUserId(authHeader);
        String operatorName = parseUsername(authHeader);

        Attendance attendance = attendanceMapper.selectById(id);
        if (attendance == null) {
            throw new BizException("打卡记录不存在");
        }

        String action = body.get("action");
        String remark = body.get("remark");
        if (action == null) {
            throw new BizException("action 不能为空");
        }

        if ("APPROVE".equals(action)) {
            attendance.setAuditStatus(1);
        } else if ("REJECT".equals(action)) {
            attendance.setAuditStatus(2);
        } else {
            throw new BizException("action 仅支持 APPROVE/REJECT");
        }
        attendance.setAuditBy(operatorId);
        attendance.setAuditAt(LocalDateTime.now());
        attendance.setAuditRemark(remark);
        attendance.setUpdatedAt(LocalDateTime.now());
        attendanceMapper.updateById(attendance);

        auditLogMapper.insert(AuditLog.builder()
                .operatorId(operatorId)
                .operatorName(operatorName)
                .action("AUDIT_" + action)
                .targetType("Attendance")
                .targetId(id)
                .targetName("打卡审核")
                .remark(remark)
                .createdAt(LocalDateTime.now())
                .build());

        return Result.ok(attendanceMapper.selectById(id));
    }

    /**
     * 补卡申请
     */
    @PostMapping("/makeup")
    public Result<Attendance> makeup(@RequestBody Map<String, Object> body,
                                     @RequestHeader("Authorization") String authHeader) {
        Long userId = parseUserId(authHeader);

        Long scheduleId = body.get("schedule_id") == null ? null : ((Number) body.get("schedule_id")).longValue();
        String reason = (String) body.get("reason");
        if (scheduleId == null) {
            throw new BizException("schedule_id 必填");
        }
        if (reason == null || reason.isBlank()) {
            throw new BizException("reason 必填");
        }

        Schedule schedule = scheduleMapper.selectById(scheduleId);
        if (schedule == null) {
            throw new BizException("排课不存在");
        }

        Attendance existing = attendanceMapper.selectOne(
                new QueryWrapper<Attendance>().eq("schedule_id", scheduleId).last("LIMIT 1"));
        if (existing != null) {
            throw new BizException("该排课已有打卡记录，不能重复补卡");
        }

        Attendance attendance = Attendance.builder()
                .scheduleId(scheduleId)
                .teacherId(schedule.getTeacherId())
                .campusId(schedule.getCampusId())
                .actualStartTime(schedule.getStartTime())
                .actualEndTime(schedule.getEndTime())
                .durationMinutes(schedule.getExpectedDuration())
                .exceptionNote(reason)
                .auditStatus(0)
                .isMakeup(0)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        attendanceMapper.insert(attendance);

        // 直接创建 + 待审核状态
        return Result.ok(attendance);
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

    /**
     * 辅助：返回通用 Map 构造
     */
    private Map<String, Object> newMap() {
        return new LinkedHashMap<>();
    }
}
