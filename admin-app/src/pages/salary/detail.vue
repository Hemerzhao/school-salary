<template>
  <view class="detail-page">
    <!-- 加载中 -->
    <view v-if="loading" class="loading">
      <text class="loading-text">加载中...</text>
    </view>

    <template v-else-if="statement">
      <!-- 金额汇总卡 -->
      <view class="summary-card">
        <view class="summary-header">
          <text class="summary-teacher">教师 #{{ statement.teacherId }}</text>
          <text
            class="status-tag"
            :style="{ color: statusInfo(statement.status).color, backgroundColor: statusInfo(statement.status).bg }"
          >
            {{ statusInfo(statement.status).text }}
          </text>
        </view>
        <text class="summary-month">结算月份：{{ statement.month }}</text>
        <view class="summary-grid">
          <view class="summary-item">
            <text class="summary-label">应发</text>
            <text class="summary-num">￥{{ formatMoney(statement.grossAmount) }}</text>
          </view>
          <view class="summary-item">
            <text class="summary-label">调整</text>
            <text class="summary-num" :class="Number(statement.adjustmentAmount) < 0 ? 'num-danger' : 'num-success'">
              ￥{{ formatMoney(statement.adjustmentAmount) }}
            </text>
          </view>
          <view class="summary-item">
            <text class="summary-label">实发</text>
            <text class="summary-num net">￥{{ formatMoney(statement.netAmount) }}</text>
          </view>
        </view>
        <view v-if="statement.paidAt" class="paid-row">
          <text class="paid-label">发放时间</text>
          <text class="paid-value">{{ statement.paidAt }}</text>
        </view>
        <view v-if="statement.paidVoucher" class="paid-row">
          <text class="paid-label">发放凭证</text>
          <text class="paid-value">{{ statement.paidVoucher }}</text>
        </view>
      </view>

      <!-- 调整项列表 -->
      <view class="section-card">
        <text class="section-title">调整项（{{ adjustments.length }}）</text>
        <view v-if="adjustments.length === 0" class="empty">
          <text class="empty-text">暂无调整项</text>
        </view>
        <view v-for="item in adjustments" :key="item.id" class="adjust-item">
          <view class="adjust-header">
            <text class="adjust-type">{{ item.adjustType }}</text>
            <text
              class="adjust-status"
              :style="{ color: item.status === 1 ? successColor : greyColor, backgroundColor: item.status === 1 ? successBg : greyBg }"
            >
              {{ adjustStatusText(item.status) }}
            </text>
          </view>
          <view class="adjust-body">
            <text class="adjust-amount" :class="Number(item.amount) < 0 ? 'amount-danger' : ''">
              金额：￥{{ formatMoney(item.amount) }}
            </text>
            <text class="adjust-reason">原因：{{ item.reason || '-' }}</text>
          </view>
        </view>
      </view>

      <!-- 工资明细列表 -->
      <view class="section-card">
        <text class="section-title">工资明细（{{ details.length }}）</text>
        <view v-if="details.length === 0" class="empty">
          <text class="empty-text">暂无明细数据</text>
        </view>
        <view v-for="item in details" :key="item.id" class="detail-item">
          <view class="detail-header">
            <text class="detail-month">{{ item.calcMonth || statement.month }}</text>
            <text class="detail-total">￥{{ formatMoney(item.detailAmount) }}</text>
          </view>
          <view class="detail-grid">
            <view class="detail-cell">
              <text class="detail-label">课时</text>
              <text class="detail-value">{{ item.hours ?? '-' }}</text>
            </view>
            <view class="detail-cell">
              <text class="detail-label">课时费</text>
              <text class="detail-value">{{ formatMoney(item.baseAmount) }}</text>
            </view>
            <view class="detail-cell">
              <text class="detail-label">人头费</text>
              <text class="detail-value">{{ formatMoney(item.headcountAmount) }}</text>
            </view>
            <view class="detail-cell">
              <text class="detail-label">时段补贴</text>
              <text class="detail-value">{{ formatMoney(item.timeSlotSubsidy) }}</text>
            </view>
            <view class="detail-cell">
              <text class="detail-label">课程奖金</text>
              <text class="detail-value">{{ formatMoney(item.courseTypeBonus) }}</text>
            </view>
            <view class="detail-cell">
              <text class="detail-label">等级奖金</text>
              <text class="detail-value">{{ formatMoney(item.levelBonus) }}</text>
            </view>
          </view>
        </view>
      </view>
    </template>

    <view v-else class="empty">
      <text class="empty-text">工资单不存在</text>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { get } from '../../utils/request'
import {
  formatMoney,
  salaryStatusInfo as statusInfo,
  adjustStatusText
} from '../../utils/format'

// 状态色常量（调整项状态 tag 用）
const successColor = '#52c41a'
const successBg = '#f6ffed'
const greyColor = '#999999'
const greyBg = '#f5f5f5'

const statementId = ref(null)
const statement = ref(null)
const details = ref([])
const adjustments = ref([])
const loading = ref(true)

// GET /salary/statement/{id} → { statement, details, adjustments, snapshots? }
async function loadDetail() {
  loading.value = true
  try {
    const data = await get('/salary/statement/' + statementId.value)
    statement.value = data.statement || null
    details.value = Array.isArray(data.details) ? data.details : []
    adjustments.value = Array.isArray(data.adjustments) ? data.adjustments : []
  } catch (e) {
    statement.value = null
  } finally {
    loading.value = false
  }
}

onLoad((query) => {
  statementId.value = query.id
  loadDetail()
})
</script>

<style lang="scss" scoped>
.detail-page {
  min-height: 100vh;
  background-color: $bg-page;
  padding: 24rpx;
  box-sizing: border-box;
  padding-bottom: env(safe-area-inset-bottom);
}

/* 汇总卡 */
.summary-card {
  background: linear-gradient(135deg, #1677ff 0%, #4d94ff 100%);
  border-radius: $radius;
  padding: 32rpx;
  color: #ffffff;
  box-shadow: 0 8rpx 24rpx rgba(22, 119, 255, 0.2);
}

.summary-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.summary-teacher {
  font-size: 32rpx;
  font-weight: bold;
  color: #ffffff;
}

.status-tag {
  font-size: 22rpx;
  padding: 6rpx 16rpx;
  border-radius: 8rpx;
}

.summary-month {
  display: block;
  margin-top: 8rpx;
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.85);
}

.summary-grid {
  display: flex;
  margin-top: 32rpx;
}

.summary-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.summary-label {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.85);
}

.summary-num {
  margin-top: 12rpx;
  font-size: 32rpx;
  font-weight: bold;
  color: #ffffff;
}

.summary-num.net {
  font-size: 36rpx;
}

.num-danger {
  color: #ffd6d6;
}

.num-success {
  color: #d9f7be;
}

.paid-row {
  display: flex;
  justify-content: space-between;
  margin-top: 20rpx;
}

.paid-label {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.75);
}

.paid-value {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.95);
}

/* 区块卡片 */
.section-card {
  background-color: #ffffff;
  border-radius: $radius;
  padding: 32rpx;
  margin-top: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.section-title {
  display: block;
  font-size: 30rpx;
  font-weight: bold;
  color: $text-main;
  margin-bottom: 8rpx;
}

/* 调整项 */
.adjust-item {
  border-bottom: 1rpx solid $border-color;
  padding: 20rpx 0;

  &:last-child {
    border-bottom: none;
  }
}

.adjust-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.adjust-type {
  font-size: 28rpx;
  font-weight: 500;
  color: $text-main;
}

.adjust-status {
  font-size: 22rpx;
  padding: 4rpx 16rpx;
  border-radius: 8rpx;
}

.adjust-body {
  margin-top: 12rpx;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.adjust-amount {
  font-size: 26rpx;
  color: $text-main;
}

.amount-danger {
  color: $danger;
}

.adjust-reason {
  font-size: 24rpx;
  color: $text-grey;
  line-height: 36rpx;
}

/* 明细 */
.detail-item {
  border-bottom: 1rpx solid $border-color;
  padding: 20rpx 0;

  &:last-child {
    border-bottom: none;
  }
}

.detail-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.detail-month {
  font-size: 28rpx;
  font-weight: 500;
  color: $text-main;
}

.detail-total {
  font-size: 30rpx;
  font-weight: bold;
  color: $primary;
}

.detail-grid {
  display: flex;
  flex-wrap: wrap;
  margin-top: 16rpx;
}

.detail-cell {
  width: 33.33%;
  display: flex;
  flex-direction: column;
  margin-bottom: 12rpx;
}

.detail-label {
  font-size: 22rpx;
  color: $text-grey;
}

.detail-value {
  margin-top: 4rpx;
  font-size: 26rpx;
  color: $text-main;
}

/* 空状态与加载 */
.empty,
.loading {
  padding: 80rpx 0;
  display: flex;
  justify-content: center;
}

.empty-text,
.loading-text {
  font-size: 26rpx;
  color: $text-grey;
}
</style>
