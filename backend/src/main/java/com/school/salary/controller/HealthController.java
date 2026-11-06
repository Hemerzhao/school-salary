package com.school.salary.controller;

import com.school.salary.common.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 健康检查（不需要 JWT，Docker / K8s / 运维监控都可以用）
 * 另外 Spring Boot Actuator 也提供标准端点 /actuator/health
 */
@RestController
@RequestMapping("/health")
public class HealthController {

    private static final String VERSION = "1.0.0";

    @GetMapping
    public Result<Map<String, Object>> health() {
        Map<String, Object> info = new LinkedHashMap<>();
        info.put("status", "UP");
        info.put("version", VERSION);
        info.put("time", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        info.put("service", "salary-backend");
        return Result.ok(info);
    }
}
