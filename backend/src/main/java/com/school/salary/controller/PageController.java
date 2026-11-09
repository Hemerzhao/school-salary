package com.school.salary.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 页面入口：把简短路径转发到实际静态页面（地址栏保持简短路径）
 * 页面放在 /h5 下，避免与 /teacher/** 等接口路径冲突
 */
@Controller
public class PageController {

    @GetMapping({"", "/", "/admin", "/admin/", "/h5", "/h5/"})
    public String adminPage() {
        return "forward:/h5/admin/index.html";
    }

    @GetMapping({"/teacher", "/teacher/", "/teacher/index.html"})
    public String teacherPage() {
        return "forward:/h5/teacher/index.html";
    }
}
