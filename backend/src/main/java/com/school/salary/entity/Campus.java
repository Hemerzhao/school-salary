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
 * 校区
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("campus")
public class Campus {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 校区名称 */
    @TableField("name")
    private String name;

    /** 地址 */
    @TableField("address")
    private String address;

    /** 校区WiFi SSID，用于打卡定位校验 */
    @TableField("wifi_ssid")
    private String wifiSsid;

    /** GPS中心点 如: 39.9042,116.4074 */
    @TableField("gps_center")
    private String gpsCenter;

    /** 打卡允许GPS半径(公里) */
    @TableField("gps_radius_km")
    private BigDecimal gpsRadiusKm;

    /** 1启用 0停用 */
    @TableField("status")
    private Integer status;

    /** 创建时间 */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /** 更新时间 */
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
