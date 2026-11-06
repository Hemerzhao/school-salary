package com.school.salary.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 后台系统用户
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("sys_user")
public class SysUser {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 登录用户名 */
    @TableField("username")
    private String username;

    /** 密码 BCrypt加密 */
    @TableField("password")
    private String password;

    /** 用户姓名 */
    @TableField("name")
    private String name;

    /** 角色 TEACHER/CAMPUS_ADMIN/JIAOWU/FINANCE/SALARY_ADMIN/SUPER_ADMIN */
    @TableField("role")
    private String role;

    /** 数据隔离：校区管理员关联本校区 */
    @TableField("campus_id")
    private Long campusId;

    /** 教师角色关联 teacher.id */
    @TableField("teacher_id")
    private Long teacherId;

    /** 1启用 0停用 */
    @TableField("status")
    private Integer status;

    /** 最后登录时间 */
    @TableField("last_login_at")
    private LocalDateTime lastLoginAt;

    /** 最后登录IP */
    @TableField("last_login_ip")
    private String lastLoginIp;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;
}
