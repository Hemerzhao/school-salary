package com.school.salary.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 规则版本
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("rule_version")
public class RuleVersion {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 模板ID */
    @TableField("template_id")
    private Long templateId;

    /** 版本号 v1/v2.1 */
    @TableField("version_no")
    private String versionNo;

    /** 固化的完整公式(含参数) */
    @TableField("formula")
    private String formula;

    /** 本版本默认参数值 JSON */
    @TableField("default_params")
    private String defaultParams;

    /** 生效开始(含) */
    @TableField("effective_from")
    private LocalDate effectiveFrom;

    /** 生效结束(含),NULL=长期 */
    @TableField("effective_to")
    private LocalDate effectiveTo;

    /** 0草稿 2已发布 3已停用 */
    @TableField("status")
    private Integer status;

    /** 变更说明 */
    @TableField("change_log")
    private String changeLog;

    /** 创建人ID */
    @TableField("created_by")
    private Long createdBy;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;
}
