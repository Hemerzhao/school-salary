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
 * 打卡记录
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("attendance")
public class Attendance {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 排课ID(一个排课最多一条打卡) */
    @TableField("schedule_id")
    private Long scheduleId;

    /** 教师ID */
    @TableField("teacher_id")
    private Long teacherId;

    /** 校区ID */
    @TableField("campus_id")
    private Long campusId;

    /** 实际开始时间(教师点打卡开始) */
    @TableField("actual_start_time")
    private LocalDateTime actualStartTime;

    /** 实际结束时间 */
    @TableField("actual_end_time")
    private LocalDateTime actualEndTime;

    /** 实际时长(分钟) */
    @TableField("duration_minutes")
    private Integer durationMinutes;

    /** 实到人数 */
    @TableField("student_count")
    private Integer studentCount;

    /** 请假人数(不算人头费) */
    @TableField("leave_count")
    private Integer leaveCount;

    /** 缺勤人数 */
    @TableField("absent_count")
    private Integer absentCount;

    /** 异常说明 */
    @TableField("exception_note")
    private String exceptionNote;

    /** 打卡定位指纹 JSON: {gps, ssid} */
    @TableField("location_fingerprint")
    private String locationFingerprint;

    /** 系统自动校验结果 JSON */
    @TableField("validation_warnings")
    private String validationWarnings;

    /** 0待审核 1通过 2驳回 */
    @TableField("audit_status")
    private Integer auditStatus;

    /** 审核人ID */
    @TableField("audit_by")
    private Long auditBy;

    /** 审核时间 */
    @TableField("audit_at")
    private LocalDateTime auditAt;

    /** 审核备注 */
    @TableField("audit_remark")
    private String auditRemark;

    /** 0否 1补卡 */
    @TableField("is_makeup")
    private Integer isMakeup;

    /** 排课事后是否调整过 */
    @TableField("schedule_adjusted")
    private Integer scheduleAdjusted;

    /** 排课是否已取消 */
    @TableField("schedule_cancelled")
    private Integer scheduleCancelled;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /** 更新时间 */
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
