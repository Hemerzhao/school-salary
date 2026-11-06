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
 * 工资计算快照
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("salary_snapshot")
public class SalarySnapshot {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 教师ID */
    @TableField("teacher_id")
    private Long teacherId;

    /** 打卡ID */
    @TableField("attendance_id")
    private Long attendanceId;

    /** 规则版本ID */
    @TableField("rule_version_id")
    private Long ruleVersionId;

    /** 快照所属月份 如:2026-11 */
    @TableField("snapshot_month")
    private String snapshotMonth;

    /** 快照生成时间 */
    @TableField("snapshot_time")
    private LocalDateTime snapshotTime;

    /** 公式快照(固化的完整公式) */
    @TableField("formula_snapshot")
    private String formulaSnapshot;

    /** 参数快照 JSON */
    @TableField("params_snapshot")
    private String paramsSnapshot;

    /** 打卡数据快照 JSON */
    @TableField("attendance_snapshot")
    private String attendanceSnapshot;

    /** 教师信息快照 JSON */
    @TableField("teacher_info_snapshot")
    private String teacherInfoSnapshot;

    /** 排课信息快照 JSON */
    @TableField("schedule_info_snapshot")
    private String scheduleInfoSnapshot;

    /** 分步计算轨迹 JSON */
    @TableField("calculation_trace")
    private String calculationTrace;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;
}
