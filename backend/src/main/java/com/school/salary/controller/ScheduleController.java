package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.Attendance;
import com.school.salary.entity.Schedule;
import com.school.salary.repository.AttendanceMapper;
import com.school.salary.repository.ScheduleMapper;
import com.school.salary.util.DateParseUtil;
import io.jsonwebtoken.Claims;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 排课管理
 */
@Slf4j
@RestController
@RequestMapping("/api/schedule")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleMapper scheduleMapper;
    private final AttendanceMapper attendanceMapper;

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
     * 创建排课 - 冲突检测
     */
    @PostMapping
    public Result<Schedule> create(@RequestBody Schedule schedule,
                                   @RequestHeader("Authorization") String authHeader) {
        Long operatorId = parseOperatorId(authHeader);

        // 冲突检测：同 teacher_id + 时间区间重叠
        if (schedule.getTeacherId() == null || schedule.getStartTime() == null || schedule.getEndTime() == null) {
            throw new BizException("教师和时间不能为空");
        }
        QueryWrapper<Schedule> conflictWrapper = new QueryWrapper<Schedule>()
                .eq("teacher_id", schedule.getTeacherId())
                .ne("status", 4) // 已取消的不算冲突
                .lt("start_time", schedule.getEndTime())
                .gt("end_time", schedule.getStartTime());
        Long conflictCount = scheduleMapper.selectCount(conflictWrapper);
        if (conflictCount != null && conflictCount > 0) {
            throw new BizException("该教师在所选时间段已有排课，存在冲突");
        }

        schedule.setCreatedBy(operatorId);
        schedule.setCreatedAt(LocalDateTime.now());
        schedule.setUpdatedAt(LocalDateTime.now());
        if (schedule.getStatus() == null) {
            schedule.setStatus(1);
        }
        scheduleMapper.insert(schedule);
        return Result.ok(schedule);
    }

    /**
     * 更新排课
     * 已有关联打卡则不能改 teacher_id / 时间，只能停（status→4）
     */
    @PutMapping("/{id}")
    public Result<Schedule> update(@PathVariable Long id, @RequestBody Schedule schedule) {
        Schedule existing = scheduleMapper.selectById(id);
        if (existing == null) {
            throw new BizException("排课不存在");
        }

        // 检查是否已有打卡
        Attendance att = attendanceMapper.selectOne(
                new QueryWrapper<Attendance>().eq("schedule_id", id).last("LIMIT 1"));

        if (att != null) {
            // 已有关联打卡：只能停（改 status），不能改 teacher_id / 时间
            if (schedule.getStatus() != null && schedule.getStatus() == 4) {
                existing.setStatus(4);
                existing.setUpdatedAt(LocalDateTime.now());
                scheduleMapper.updateById(existing);
                return Result.ok(scheduleMapper.selectById(id));
            }
            // 其他字段变更
            boolean teacherChanged = schedule.getTeacherId() != null && !schedule.getTeacherId().equals(existing.getTeacherId());
            boolean timeChanged = (schedule.getStartTime() != null && !schedule.getStartTime().equals(existing.getStartTime()))
                    || (schedule.getEndTime() != null && !schedule.getEndTime().equals(existing.getEndTime()));
            if (teacherChanged || timeChanged) {
                throw new BizException("该排课已有打卡记录，不能修改教师或时间，仅能停课");
            }
        }

        // 无打卡：允许修改
        schedule.setId(id);
        schedule.setUpdatedAt(LocalDateTime.now());
        scheduleMapper.updateById(schedule);
        return Result.ok(scheduleMapper.selectById(id));
    }

    /**
     * 停课并删除打卡关联
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        Schedule existing = scheduleMapper.selectById(id);
        if (existing == null) {
            throw new BizException("排课不存在");
        }
        // 先删除关联打卡
        attendanceMapper.delete(new QueryWrapper<Attendance>().eq("schedule_id", id));
        // 再删除排课
        scheduleMapper.deleteById(id);
        return Result.ok();
    }

    /**
     * 列表筛选
     */
    @GetMapping("/list")
    public Result<List<Schedule>> list(
            @RequestParam(required = false) Long teacherId,
            @RequestParam(required = false) Long campusId,
            @RequestParam(required = false) Long classId,
            @RequestParam(required = false) String startFrom,
            @RequestParam(required = false) String startTo) {
        QueryWrapper<Schedule> wrapper = new QueryWrapper<>();
        if (teacherId != null) {
            wrapper.eq("teacher_id", teacherId);
        }
        if (campusId != null) {
            wrapper.eq("campus_id", campusId);
        }
        if (classId != null) {
            wrapper.eq("class_id", classId);
        }
        if (startFrom != null && !startFrom.isBlank()) {
            wrapper.ge("start_time", DateParseUtil.parseFlexible(startFrom));
        }
        if (startTo != null && !startTo.isBlank()) {
            wrapper.le("start_time", DateParseUtil.parseFlexible(startTo));
        }
        wrapper.orderByDesc("start_time");
        return Result.ok(scheduleMapper.selectList(wrapper));
    }

    /**
     * 分页
     */
    @GetMapping("/page")
    public Result<Page<Schedule>> page(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Long teacherId,
            @RequestParam(required = false) Long campusId,
            @RequestParam(required = false) Long classId,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String startFrom,
            @RequestParam(required = false) String startTo) {
        QueryWrapper<Schedule> wrapper = new QueryWrapper<>();
        if (teacherId != null) {
            wrapper.eq("teacher_id", teacherId);
        }
        if (campusId != null) {
            wrapper.eq("campus_id", campusId);
        }
        if (classId != null) {
            wrapper.eq("class_id", classId);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        if (startFrom != null && !startFrom.isBlank()) {
            wrapper.ge("start_time", DateParseUtil.parseFlexible(startFrom));
        }
        if (startTo != null && !startTo.isBlank()) {
            wrapper.le("start_time", DateParseUtil.parseFlexible(startTo));
        }
        wrapper.orderByDesc("start_time");
        return Result.ok(scheduleMapper.selectPage(new Page<>(current, size), wrapper));
    }

    private Long parseOperatorId(String authHeader) {
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
}
