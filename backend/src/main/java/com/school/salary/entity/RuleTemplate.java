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
 * 计费规则模板
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("rule_template")
public class RuleTemplate {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 模板名称 如:K12标准课时费模板 */
    @TableField("name")
    private String name;

    /** 描述 */
    @TableField("description")
    private String description;

    /** 公式骨架 如:base_rate * hours + headcount_amount + course_bonus + level_bonus + time_slot_subsidy */
    @TableField("formula_template")
    private String formulaTemplate;

    /** 参数定义数组 JSON */
    @TableField("param_schema")
    private String paramSchema;

    /** 支持的维度 JSON */
    @TableField("supported_dimensions")
    private String supportedDimensions;

    /** 1启用 0停用 */
    @TableField("status")
    private Integer status;

    /** 创建人ID */
    @TableField("created_by")
    private Long createdBy;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /** 更新时间 */
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
