package com.school.salary;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.school.salary.repository")
public class SalaryApplication {
    public static void main(String[] args) {
        SpringApplication.run(SalaryApplication.class, args);
    }
}
