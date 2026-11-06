package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.school.salary.common.Result;
import com.school.salary.entity.Course;
import com.school.salary.repository.CourseMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 枚举 / 下拉选项
 */
@Slf4j
@RestController
@RequestMapping("/config")
@RequiredArgsConstructor
public class ConfigController {

    private final CourseMapper courseMapper;

    @GetMapping("/enums")
    public Result<java.util.Map<String, Object>> enums() {
        java.util.Map<String, Object> data = new java.util.LinkedHashMap<>();

        // 教师等级
        data.put("teacher_levels", Arrays.asList("T1", "T2", "T3", "Senior"));

        // 用工类型
        data.put("employment_types", Arrays.asList("FULL", "PART"));

        // 课程类型 - 从 course 表 distinct
        List<Course> courses = courseMapper.selectList(
                new QueryWrapper<Course>()
                        .select("DISTINCT course_type")
                        .isNotNull("course_type"));
        List<String> courseTypes = courses.stream()
                .map(Course::getCourseType)
                .filter(t -> t != null && !t.isBlank())
                .distinct()
                .collect(Collectors.toList());
        data.put("course_types", courseTypes);

        return Result.ok(data);
    }
}
