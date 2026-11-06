package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.Course;
import com.school.salary.repository.CourseMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 课程管理
 */
@Slf4j
@RestController
@RequestMapping("/course")
@RequiredArgsConstructor
public class CourseController {

    private final CourseMapper courseMapper;

    @PostMapping
    public Result<Course> create(@RequestBody Course course) {
        course.setCreatedAt(LocalDateTime.now());
        course.setUpdatedAt(LocalDateTime.now());
        courseMapper.insert(course);
        return Result.ok(course);
    }

    @PutMapping("/{id}")
    public Result<Course> update(@PathVariable Long id, @RequestBody Course course) {
        Course existing = courseMapper.selectById(id);
        if (existing == null) {
            throw new BizException("课程不存在");
        }
        course.setId(id);
        course.setUpdatedAt(LocalDateTime.now());
        courseMapper.updateById(course);
        return Result.ok(courseMapper.selectById(id));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        Course existing = courseMapper.selectById(id);
        if (existing == null) {
            throw new BizException("课程不存在");
        }
        courseMapper.deleteById(id);
        return Result.ok();
    }

    @GetMapping("/{id}")
    public Result<Course> getById(@PathVariable Long id) {
        Course course = courseMapper.selectById(id);
        if (course == null) {
            throw new BizException("课程不存在");
        }
        return Result.ok(course);
    }

    @GetMapping("/list")
    public Result<List<Course>> list(
            @RequestParam(required = false) String courseType,
            @RequestParam(required = false) Integer status) {
        QueryWrapper<Course> wrapper = new QueryWrapper<>();
        if (courseType != null && !courseType.isBlank()) {
            wrapper.eq("course_type", courseType);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("id");
        return Result.ok(courseMapper.selectList(wrapper));
    }
}
