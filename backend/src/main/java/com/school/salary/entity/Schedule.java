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
 * 排课
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("schedule")
public class Schedule {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 教师ID */
    @TableField("teacher_id")
    private Long teacherId;

    /** 班级ID */
    @TableField("class_id")
    private Long classId;

    /** 课程ID */
    @TableField("course_id")
    private Long courseId;

    /** 校区ID */
    @TableField("campus_id")
    private Long campusId;

    /** 计划开始时间 */
    @TableField("start_time")
    private LocalDateTime startTime;

    /** 计划结束时间 */
    @TableField("end_time")
    private LocalDateTime endTime;

    /** 计划时长(分钟) */
    @TableField("expected_duration")
    private Integer expectedDuration;

    /** NORMAL正常(计入工资)/TRIAL试听(不计)/SUPPLEMENT补课(不计) */
    @TableField("schedule_type")
    private String scheduleType;

    /** 1待上 2进行中 3已完成 4已取消 */
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
