package com.school.salary.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 工资明细
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("salary_detail")
public class SalaryDetail {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 聚合到工资单后回填 */
    @TableField("statement_id")
    private Long statementId;

    /** 教师ID */
    @TableField("teacher_id")
    private Long teacherId;

    /** 打卡ID */
    @TableField("attendance_id")
    private Long attendanceId;

    /** 排课ID */
    @TableField("schedule_id")
    private Long scheduleId;

    /** 计算月份 如:2026-11 */
    @TableField("calc_month")
    private String calcMonth;

    /** 课时数=时长分钟/60 */
    @TableField("hours")
    private BigDecimal hours;

    /** 基础课时费 */
    @TableField("base_amount")
    private BigDecimal baseAmount;

    /** 人头费 */
    @TableField("headcount_amount")
    private BigDecimal headcountAmount;

    /** 课程类型奖金 */
    @TableField("course_type_bonus")
    private BigDecimal courseTypeBonus;

    /** 教师等级奖金 */
    @TableField("level_bonus")
    private BigDecimal levelBonus;

    /** 时段补贴 */
    @TableField("time_slot_subsidy")
    private BigDecimal timeSlotSubsidy;

    /** 合计金额 */
    @TableField("detail_amount")
    private BigDecimal detailAmount;

    /** 规则版本ID */
    @TableField("rule_version_id")
    private Long ruleVersionId;

    /** 快照ID */
    @TableField("snapshot_id")
    private Long snapshotId;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;
}
