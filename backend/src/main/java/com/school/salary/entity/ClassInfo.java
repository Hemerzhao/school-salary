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
 * 班级
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("class_info")
public class ClassInfo {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 班级名称 */
    @TableField("name")
    private String name;

    /** 校区ID */
    @TableField("campus_id")
    private Long campusId;

    /** 课程类型 K12/少儿编程/美术... */
    @TableField("course_type")
    private String courseType;

    /** 年级 */
    @TableField("grade")
    private String grade;

    /** 最大学生人数 */
    @TableField("max_students")
    private Integer maxStudents;

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
