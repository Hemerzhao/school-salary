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
 * 审计日志
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("audit_log")
public class AuditLog {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 操作人ID */
    @TableField("operator_id")
    private Long operatorId;

    /** 操作人姓名 */
    @TableField("operator_name")
    private String operatorName;

    /** 操作类型 CREATE/UPDATE/DELETE/PUBLISH/LOCK/EXPORT/CALC */
    @TableField("action")
    private String action;

    /** 目标对象类型 */
    @TableField("target_type")
    private String targetType;

    /** 目标对象ID */
    @TableField("target_id")
    private Long targetId;

    /** 目标对象名称 */
    @TableField("target_name")
    private String targetName;

    /** 变更前值 JSON */
    @TableField("before_value")
    private String beforeValue;

    /** 变更后值 JSON */
    @TableField("after_value")
    private String afterValue;

    /** 备注 */
    @TableField("remark")
    private String remark;

    /** 客户端IP */
    @TableField("client_ip")
    private String clientIp;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;
}
