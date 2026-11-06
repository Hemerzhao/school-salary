package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.Teacher;
import com.school.salary.repository.TeacherMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 教师管理
 */
@Slf4j
@RestController
@RequestMapping("/teacher")
@RequiredArgsConstructor
public class TeacherController {

    private final TeacherMapper teacherMapper;

    @PostMapping
    public Result<Teacher> create(@RequestBody Teacher teacher) {
        checkEmployeeNoUnique(teacher.getEmployeeNo(), null);
        teacher.setCreatedAt(LocalDateTime.now());
        teacher.setUpdatedAt(LocalDateTime.now());
        teacherMapper.insert(teacher);
        return Result.ok(teacher);
    }

    @PutMapping("/{id}")
    public Result<Teacher> update(@PathVariable Long id, @RequestBody Teacher teacher) {
        Teacher existing = teacherMapper.selectById(id);
        if (existing == null) {
            throw new BizException("教师不存在");
        }
        checkEmployeeNoUnique(teacher.getEmployeeNo(), id);
        teacher.setId(id);
        teacher.setUpdatedAt(LocalDateTime.now());
        teacherMapper.updateById(teacher);
        return Result.ok(teacherMapper.selectById(id));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        Teacher existing = teacherMapper.selectById(id);
        if (existing == null) {
            throw new BizException("教师不存在");
        }
        teacherMapper.deleteById(id);
        return Result.ok();
    }

    @GetMapping("/{id}")
    public Result<Teacher> getById(@PathVariable Long id) {
        Teacher teacher = teacherMapper.selectById(id);
        if (teacher == null) {
            throw new BizException("教师不存在");
        }
        return Result.ok(teacher);
    }

    @GetMapping("/list")
    public Result<List<Teacher>> list(
            @RequestParam(required = false) Long campusId,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) Integer status) {
        QueryWrapper<Teacher> wrapper = new QueryWrapper<>();
        if (campusId != null) {
            wrapper.eq("campus_id", campusId);
        }
        if (level != null && !level.isBlank()) {
            wrapper.eq("level", level);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("id");
        return Result.ok(teacherMapper.selectList(wrapper));
    }

    @GetMapping("/page")
    public Result<Page<Teacher>> page(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Long campusId,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword) {
        QueryWrapper<Teacher> wrapper = new QueryWrapper<>();
        if (campusId != null) {
            wrapper.eq("campus_id", campusId);
        }
        if (level != null && !level.isBlank()) {
            wrapper.eq("level", level);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like("name", keyword).or().like("employee_no", keyword).or().like("phone", keyword));
        }
        wrapper.orderByDesc("id");
        return Result.ok(teacherMapper.selectPage(new Page<>(current, size), wrapper));
    }

    private void checkEmployeeNoUnique(String employeeNo, Long excludeId) {
        if (employeeNo == null || employeeNo.isBlank()) {
            return;
        }
        QueryWrapper<Teacher> wrapper = new QueryWrapper<Teacher>().eq("employee_no", employeeNo);
        if (excludeId != null) {
            wrapper.ne("id", excludeId);
        }
        Long count = teacherMapper.selectCount(wrapper);
        if (count != null && count > 0) {
            throw new BizException("工号已存在: " + employeeNo);
        }
    }
}
