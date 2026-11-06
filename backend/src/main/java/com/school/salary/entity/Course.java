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
 * 课程
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("course")
public class Course {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 课程名称 */
    @TableField("name")
    private String name;

    /** 课程类型 */
    @TableField("course_type")
    private String courseType;

    /** 默认单课时总时长(分钟) */
    @TableField("default_duration_min")
    private Integer defaultDurationMin;

    /** 状态 1启用 0停用 */
    @TableField("status")
    private Integer status;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /** 更新时间 */
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
