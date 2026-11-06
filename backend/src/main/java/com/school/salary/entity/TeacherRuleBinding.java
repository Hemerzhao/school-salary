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
 * 教师规则绑定
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("teacher_rule_binding")
public class TeacherRuleBinding {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 教师ID */
    @TableField("teacher_id")
    private Long teacherId;

    /** 规则版本ID */
    @TableField("rule_version_id")
    private Long ruleVersionId;

    /** 生效开始(含) */
    @TableField("effective_from")
    private LocalDate effectiveFrom;

    /** 生效结束(含),NULL=长期 */
    @TableField("effective_to")
    private LocalDate effectiveTo;

    /** 教师个性化覆盖参数 JSON, null表示用版本默认值 */
    @TableField("param_overrides")
    private String paramOverrides;

    /** 优先级 同时段多绑定时取高优先级 */
    @TableField("priority")
    private Integer priority;

    /** 创建人ID */
    @TableField("created_by")
    private Long createdBy;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;
}
