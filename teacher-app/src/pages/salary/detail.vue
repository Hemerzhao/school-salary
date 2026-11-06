<template>
  <view class="page">
    <view v-if="loading" class="empty-card">
      <text class="empty-text">加载中...</text>
    </view>

    <template v-else-if="statement">
      <!-- 金额汇总卡片 -->
      <view class="summary-card">
        <view class="summary-top">
          <text class="summary-month">{{ statement.month }} 工资单</text>
          <text class="summary-status">{{ salaryStatusText(statement.status) }}</text>
        </view>
        <text class="summary-net">¥ {{ formatMoney(statement.netAmount) }}</text>
        <view class="summary-row">
          <view class="summary-item">
            <text class="summary-label">应发金额</text>
            <text class="summary-value">¥{{ formatMoney(statement.grossAmount) }}</text>
          </view>
          <view class="summary-item">
            <text class="summary-label">调整金额</text>
            <text class="summary-value">¥{{ formatMoney(statement.adjustmentAmount) }}</text>
          </view>
          <view class="summary-item">
            <text class="summary-label">实发金额</text>
            <text class="summary-value">¥{{ formatMoney(statement.netAmount) }}</text>
          </view>
        </view>
      </view>

      <!-- 调整项列表 -->
      <template v-if="adjustments.length > 0">
        <view class="section-title">
          <text>调整项</text>
        </view>
        <view v-for="adj in adjustments" :key="adj.id" class="adjust-card">
          <view class="adjust-row">
            <text class="adjust-name">{{ adj.name || adj.title || '调整项' }}</text>
            <text class="adjust-amount">
              ¥{{ formatMoney(adj.amount != null ? adj.amount : adj.adjustmentAmount) }}
            </text>
          </view>
          <text v-if="adj.remark" class="adjust-remark">{{ adj.remark }}</text>
        </view>
      </template>

      <!-- 课时明细列表（点击展开完整分项） -->
      <view class="section-title">
        <text>课时明细</text>
      </view>

      <view v-if="details.length === 0" class="empty-card">
        <text class="empty-text">暂无课时明细</text>
      </view>
      <template v-else>
        <view v-for="d in details" :key="d.id" class="detail-card" @click="toggle(d.id)">
          <view class="detail-summary">
            <view class="detail-left">
              <text class="detail-title">{{ d.calcMonth }} 课时记录</text>
              <text class="detail-hours">{{ d.hours }} 课时</text>
            </view>
            <text class="detail-amount">¥{{ formatMoney(d.detailAmount) }}</text>
          </view>
          <view class="detail-brief">
            <text class="brief-item">基础 ¥{{ formatMoney(d.baseAmount) }}</text>
            <text class="brief-item">人数 ¥{{ formatMoney(d.headcountAmount) }}</text>
            <text class="brief-item">时段 ¥{{ formatMoney(d.timeSlotSubsidy) }}</text>
          </view>
          <view v-if="expandedId === d.id" class="detail-expand">
            <view class="expand-row">
              <text class="expand-label">基础课时费</text>
              <text class="expand-value">¥{{ formatMoney(d.baseAmount) }}</text>
            </view>
            <view class="expand-row">
              <text class="expand-label">人数奖金</text>
              <text class="expand-value">¥{{ formatMoney(d.headcountAmount) }}</text>
            </view>
            <view class="expand-row">
              <text class="expand-label">课程类型奖金</text>
              <text class="expand-value">¥{{ formatMoney(d.courseTypeBonus) }}</text>
            </view>
            <view class="expand-row">
              <text class="expand-label">级别奖金</text>
              <text class="expand-value">¥{{ formatMoney(d.levelBonus) }}</text>
            </view>
            <view class="expand-row">
              <text class="expand-label">时段补贴</text>
              <text class="expand-value">¥{{ formatMoney(d.timeSlotSubsidy) }}</text>
            </view>
            <view class="expand-row">
              <text class="expand-label">关联打卡 ID</text>
              <text class="expand-value">{{ d.attendanceId != null ? d.attendanceId : '-' }}</text>
            </view>
          </view>
          <view class="expand-toggle">
            <text class="toggle-text">{{ expandedId === d.id ? '收起 ▲' : '展开明细 ▼' }}</text>
          </view>
        </view>
      </template>
    </template>

    <view v-else class="empty-card">
      <text class="empty-text">工资单不存在或已删除</text>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { statementDetail } from '../../services/salary'
import { formatMoney, salaryStatusText } from '../../utils/format'

const statement = ref(null)
const details = ref([])
const adjustments = ref([])
const expandedId = ref(null)
const loading = ref(true)

// 点击明细卡片切换展开/收起
function toggle(id) {
  expandedId.value = expandedId.value === id ? null : id
}

onLoad(async (query) => {
  try {
    const data = await statementDetail(query.id)
    statement.value = (data && data.statement) || null
    details.value = (data && data.details) || []
    adjustments.value = (data && data.adjustments) || []
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    loading.value = false
  }
})
</script>

<style lang="scss" scoped>
.page {
  padding: 24rpx;
}

.summary-card {
  background: linear-gradient(135deg, $primary 0%, #4d94ff 100%);
  border-radius: $radius;
  padding: 36rpx 32rpx;
  margin-bottom: 24rpx;
  display: flex;
  flex-direction: column;
}

.summary-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.summary-month {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
}

.summary-status {
  font-size: 22rpx;
  color: #ffffff;
  background-color: rgba(255, 255, 255, 0.2);
  padding: 4rpx 20rpx;
  border-radius: 24rpx;
}

.summary-net {
  margin-top: 24rpx;
  font-size: 64rpx;
  font-weight: bold;
  color: #ffffff;
}

.summary-row {
  margin-top: 32rpx;
  display: flex;
}

.summary-item {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.summary-label {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.8);
}

.summary-value {
  margin-top: 8rpx;
  font-size: 30rpx;
  font-weight: bold;
  color: #ffffff;
}

.section-title {
  padding: 8rpx 8rpx 16rpx;
  font-size: 28rpx;
  color: $text-sub;
}

.adjust-card,
.detail-card,
.empty-card {
  background-color: $bg-card;
  border-radius: $radius;
  padding: 28rpx;
  margin-bottom: 20rpx;
}

.empty-card {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 80rpx 28rpx;
}

.empty-text {
  font-size: 28rpx;
  color: $text-grey;
}

.adjust-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.adjust-name {
  font-size: 28rpx;
  color: $text-main;
}

.adjust-amount {
  font-size: 30rpx;
  font-weight: bold;
  color: $warning;
}

.adjust-remark {
  display: block;
  margin-top: 12rpx;
  font-size: 24rpx;
  color: $text-grey;
}

.detail-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.detail-left {
  display: flex;
  flex-direction: column;
}

.detail-title {
  font-size: 28rpx;
  font-weight: bold;
  color: $text-main;
}

.detail-hours {
  margin-top: 8rpx;
  font-size: 24rpx;
  color: $text-grey;
}

.detail-amount {
  font-size: 36rpx;
  font-weight: bold;
  color: $primary;
}

.detail-brief {
  margin-top: 20rpx;
  display: flex;
}

.brief-item {
  font-size: 24rpx;
  color: $text-sub;
  margin-right: 32rpx;
}

.detail-expand {
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid $border-color;
}

.expand-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 64rpx;
}

.expand-label {
  font-size: 26rpx;
  color: $text-sub;
}

.expand-value {
  font-size: 26rpx;
  color: $text-main;
  font-weight: 500;
}

.expand-toggle {
  margin-top: 16rpx;
  display: flex;
  justify-content: center;
}

.toggle-text {
  font-size: 24rpx;
  color: $primary;
}
</style>
