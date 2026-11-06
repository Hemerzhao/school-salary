package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.Campus;
import com.school.salary.repository.CampusMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 校区管理
 */
@Slf4j
@RestController
@RequestMapping("/campus")
@RequiredArgsConstructor
public class CampusController {

    private final CampusMapper campusMapper;

    @PostMapping
    public Result<Campus> create(@RequestBody Campus campus) {
        campus.setCreatedAt(LocalDateTime.now());
        campus.setUpdatedAt(LocalDateTime.now());
        campusMapper.insert(campus);
        return Result.ok(campus);
    }

    @PutMapping("/{id}")
    public Result<Campus> update(@PathVariable Long id, @RequestBody Campus campus) {
        Campus existing = campusMapper.selectById(id);
        if (existing == null) {
            throw new BizException("校区不存在");
        }
        campus.setId(id);
        campus.setUpdatedAt(LocalDateTime.now());
        campusMapper.updateById(campus);
        return Result.ok(campusMapper.selectById(id));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        Campus existing = campusMapper.selectById(id);
        if (existing == null) {
            throw new BizException("校区不存在");
        }
        campusMapper.deleteById(id);
        return Result.ok();
    }

    @GetMapping("/{id}")
    public Result<Campus> getById(@PathVariable Long id) {
        Campus campus = campusMapper.selectById(id);
        if (campus == null) {
            throw new BizException("校区不存在");
        }
        return Result.ok(campus);
    }

    @GetMapping("/list")
    public Result<java.util.List<Campus>> list() {
        return Result.ok(campusMapper.selectList(new QueryWrapper<Campus>().orderByDesc("id")));
    }

    @GetMapping("/page")
    public Result<Page<Campus>> page(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) Integer status) {
        QueryWrapper<Campus> wrapper = new QueryWrapper<>();
        if (name != null && !name.isBlank()) {
            wrapper.like("name", name);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("id");
        return Result.ok(campusMapper.selectPage(new Page<>(current, size), wrapper));
    }
}
