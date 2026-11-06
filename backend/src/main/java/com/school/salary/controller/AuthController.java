package com.school.salary.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.school.salary.common.BizException;
import com.school.salary.common.Result;
import com.school.salary.entity.SysUser;
import com.school.salary.repository.SysUserMapper;
import com.school.salary.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 登录 & 当前用户信息
 */
@Slf4j
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final SysUserMapper sysUserMapper;
    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expire-hours}")
    private long jwtExpireHours;

    private JwtUtil jwtUtil;

    @PostConstruct
    public void init() {
        this.jwtUtil = new JwtUtil(jwtSecret, jwtExpireHours * 3600);
    }

    /**
     * 登录
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        if (username == null || password == null) {
            throw new BizException("用户名或密码不能为空");
        }

        SysUser user = sysUserMapper.selectOne(
                new QueryWrapper<SysUser>().eq("username", username));
        if (user == null) {
            throw new BizException("用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() != 1) {
            throw new BizException("账号已停用");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BizException("用户名或密码错误");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole(), user.getCampusId());

        Map<String, Object> userInfo = new LinkedHashMap<>();
        userInfo.put("id", user.getId());
        userInfo.put("username", user.getUsername());
        userInfo.put("name", user.getName());
        userInfo.put("role", user.getRole());
        userInfo.put("campusId", user.getCampusId());

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("token", token);
        resp.put("user", userInfo);
        return Result.ok(resp);
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/profile")
    public Result<Map<String, Object>> profile(@RequestHeader("Authorization") String authHeader) {
        String token = parseToken(authHeader);
        Claims claims;
        try {
            claims = jwtUtil.parseClaims(token);
        } catch (Exception e) {
            throw new BizException(401, "登录已过期，请重新登录");
        }

        Long userId = ((Number) claims.get("userId")).longValue();
        SysUser user = sysUserMapper.selectById(userId);
        if (user == null) {
            throw new BizException("用户不存在");
        }

        Map<String, Object> userInfo = new LinkedHashMap<>();
        userInfo.put("id", user.getId());
        userInfo.put("username", user.getUsername());
        userInfo.put("name", user.getName());
        userInfo.put("role", user.getRole());
        userInfo.put("campusId", user.getCampusId());
        userInfo.put("teacherId", user.getTeacherId());
        userInfo.put("status", user.getStatus());
        return Result.ok(userInfo);
    }

    private String parseToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new BizException(401, "缺少 Authorization");
        }
        return authHeader.substring("Bearer ".length());
    }
}
