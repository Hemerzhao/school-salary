package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.ClassInfo;
import com.school.salary.repository.ClassInfoMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 班级管理
 * 实体类名 ClassInfo（避免与 Java 关键字 Class 冲突）
 */
@Slf4j
@RestController
@RequestMapping("/class")
@RequiredArgsConstructor
public class ClassController {

    private final ClassInfoMapper classInfoMapper;

    @PostMapping
    public Result<ClassInfo> create(@RequestBody ClassInfo classInfo) {
        classInfo.setCreatedAt(LocalDateTime.now());
        classInfo.setUpdatedAt(LocalDateTime.now());
        classInfoMapper.insert(classInfo);
        return Result.ok(classInfo);
    }

    @PutMapping("/{id}")
    public Result<ClassInfo> update(@PathVariable Long id, @RequestBody ClassInfo classInfo) {
        ClassInfo existing = classInfoMapper.selectById(id);
        if (existing == null) {
            throw new BizException("班级不存在");
        }
        classInfo.setId(id);
        classInfo.setUpdatedAt(LocalDateTime.now());
        classInfoMapper.updateById(classInfo);
        return Result.ok(classInfoMapper.selectById(id));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        ClassInfo existing = classInfoMapper.selectById(id);
        if (existing == null) {
            throw new BizException("班级不存在");
        }
        classInfoMapper.deleteById(id);
        return Result.ok();
    }

    @GetMapping("/{id}")
    public Result<ClassInfo> getById(@PathVariable Long id) {
        ClassInfo classInfo = classInfoMapper.selectById(id);
        if (classInfo == null) {
            throw new BizException("班级不存在");
        }
        return Result.ok(classInfo);
    }

    @GetMapping("/list")
    public Result<List<ClassInfo>> list(
            @RequestParam(required = false) Long campusId,
            @RequestParam(required = false) Integer status) {
        QueryWrapper<ClassInfo> wrapper = new QueryWrapper<>();
        if (campusId != null) {
            wrapper.eq("campus_id", campusId);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("id");
        return Result.ok(classInfoMapper.selectList(wrapper));
    }
}
