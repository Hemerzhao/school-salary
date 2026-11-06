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
 * 教师
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("teacher")
public class Teacher {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 教师姓名 */
    @TableField("name")
    private String name;

    /** 手机号 */
    @TableField("phone")
    private String phone;

    /** 工号 */
    @TableField("employee_no")
    private String employeeNo;

    /** 微信openid，教师端登录用 */
    @TableField("openid")
    private String openid;

    /** 主校区ID */
    @TableField("campus_id")
    private Long campusId;

    /** 教师等级 T1/T2/T3/Senior */
    @TableField("level")
    private String level;

    /** FULL全职/PART兼职 */
    @TableField("employment_type")
    private String employmentType;

    /** 1在职 0离职 */
    @TableField("status")
    private Integer status;

    /** 银行卡号(AES加密) */
    @TableField("bank_account")
    private String bankAccount;

    /** 身份证号(AES加密) */
    @TableField("id_card")
    private String idCard;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /** 更新时间 */
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
