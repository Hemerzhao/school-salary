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
 * 调整项
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("adjustment_item")
public class AdjustmentItem {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 工资单ID */
    @TableField("statement_id")
    private Long statementId;

    /** 教师ID */
    @TableField("teacher_id")
    private Long teacherId;

    /** 月份 2026-11 */
    @TableField("month")
    private String month;

    /** 补发/扣款/奖金/其他 */
    @TableField("adjust_type")
    private String adjustType;

    /** 调整金额 正=增加 负=减少 */
    @TableField("amount")
    private BigDecimal amount;

    /** 原因说明 */
    @TableField("reason")
    private String reason;

    /** 关联打卡ID */
    @TableField("related_attendance_id")
    private Long relatedAttendanceId;

    /** 0草稿 1已确认 */
    @TableField("status")
    private Integer status;

    /** 申请人ID */
    @TableField("apply_by")
    private Long applyBy;

    /** 申请时间 */
    @TableField("apply_at")
    private LocalDateTime applyAt;
}
