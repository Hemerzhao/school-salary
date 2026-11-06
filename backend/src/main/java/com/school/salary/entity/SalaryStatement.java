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
 * 工资单
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("salary_statement")
public class SalaryStatement {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 教师ID */
    @TableField("teacher_id")
    private Long teacherId;

    /** 校区ID */
    @TableField("campus_id")
    private Long campusId;

    /** 工资月份 2026-11 */
    @TableField("month")
    private String month;

    /** 应发合计 */
    @TableField("gross_amount")
    private BigDecimal grossAmount;

    /** 调整项合计 */
    @TableField("adjustment_amount")
    private BigDecimal adjustmentAmount;

    /** 实发合计=应发+调整 */
    @TableField("net_amount")
    private BigDecimal netAmount;

    /** 0草稿 1已确认 2已锁定 3已发放 */
    @TableField("status")
    private Integer status;

    /** 锁定时间 */
    @TableField("locked_at")
    private LocalDateTime lockedAt;

    /** 锁定人ID */
    @TableField("locked_by")
    private Long lockedBy;

    /** 发放时间 */
    @TableField("paid_at")
    private LocalDateTime paidAt;

    /** 发放凭证号 */
    @TableField("paid_voucher")
    private String paidVoucher;

    /** 备注 */
    @TableField("remark")
    private String remark;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /** 更新时间 */
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
