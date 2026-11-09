package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.Campus;
import com.school.salary.entity.SysUser;
import com.school.salary.entity.Teacher;
import com.school.salary.repository.CampusMapper;
import com.school.salary.repository.SysUserMapper;
import com.school.salary.repository.TeacherMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * 教师管理
 */
@Slf4j
@RestController
@RequestMapping("/teacher")
@RequiredArgsConstructor
public class TeacherController {

    private final TeacherMapper teacherMapper;
    private final SysUserMapper sysUserMapper;
    private final CampusMapper campusMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /**
     * 注册教师账号：一次完成「创建登录账号 + 创建教师档案」
     * 请求体：{ name, account, password, level, phone }
     */
    @PostMapping("/register")
    @Transactional(rollbackFor = Exception.class)
    public Result<Teacher> register(@RequestBody Map<String, Object> body) {
        String name = str(body.get("name"));
        String account = str(body.get("account"));
        String password = str(body.get("password"));
        String level = str(body.get("level"));
        String phone = str(body.get("phone"));

        if (name == null || name.isBlank()) {
            throw new BizException("请填写教师姓名");
        }
        if (account == null || account.isBlank()) {
            throw new BizException("请填写登录账号");
        }
        if (password == null || password.isBlank()) {
            throw new BizException("请填写初始密码");
        }

        // 1. 账号唯一性校验
        Long exists = sysUserMapper.selectCount(new QueryWrapper<SysUser>().eq("username", account));
        if (exists != null && exists > 0) {
            throw new BizException("账号已存在: " + account);
        }

        LocalDateTime now = LocalDateTime.now();

        // 校区：请求未指定时归入第一个启用校区（campus_id 为 NOT NULL）
        Long campusId = null;
        Object campusVal = body.get("campusId");
        if (campusVal != null && !String.valueOf(campusVal).isBlank()) {
            campusId = Long.valueOf(String.valueOf(campusVal));
        } else {
            List<Campus> campuses = campusMapper.selectList(
                    new QueryWrapper<Campus>().eq("status", 1).orderByAsc("id"));
            if (campuses.isEmpty()) {
                throw new BizException("请先创建校区后再注册教师");
            }
            campusId = campuses.get(0).getId();
        }

        // 2. 创建教师档案（工号自动生成，employee_no 为 NOT NULL）
        Teacher teacher = Teacher.builder()
                .name(name)
                .phone(phone)
                .employeeNo("T" + now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")))
                .campusId(campusId)
                .level(level == null || level.isBlank() ? "P2" : level)
                .employmentType("FULL")
                .status(1)
                .createdAt(now)
                .updatedAt(now)
                .build();
        teacherMapper.insert(teacher);

        // 3. 创建登录账号并回填 teacher_id
        SysUser user = SysUser.builder()
                .username(account)
                .password(passwordEncoder.encode(password))
                .name(name)
                .role("TEACHER")
                .teacherId(teacher.getId())
                .status(1)
                .createdAt(now)
                .build();
        sysUserMapper.insert(user);

        log.info("注册教师成功: account={}, name={}, teacherId={}", account, name, teacher.getId());
        return Result.ok(teacher);
    }

    private String str(Object v) {
        return v == null ? null : String.valueOf(v);
    }

    @PostMapping
    public Result<Teacher> create(@RequestBody Teacher teacher) {
        if (teacher.getEmployeeNo() == null || teacher.getEmployeeNo().isBlank()) {
            teacher.setEmployeeNo("T" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
        }
        checkEmployeeNoUnique(teacher.getEmployeeNo(), null);
        teacher.setCreatedAt(LocalDateTime.now());
        teacher.setUpdatedAt(LocalDateTime.now());
        if (teacher.getStatus() == null) {
            teacher.setStatus(1);
        }
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
