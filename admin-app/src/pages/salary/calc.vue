<template>
  <view class="calc-page">
    <!-- 权限提示 -->
    <view v-if="!allowed" class="no-perm">
      <text class="no-perm-text">当前角色无权使用工资模块</text>
    </view>

    <template v-else>
      <!-- 月份选择 + 触发计算 -->
      <view class="card">
        <text class="card-title">月度工资计算</text>
        <text class="card-desc">选择月份后触发计算，系统将按规则重算当月全部教师工资明细</text>
        <view class="month-row">
          <text class="month-label">计算月份</text>
          <picker class="month-picker" mode="date" fields="month" :value="month" @change="onMonthChange">
            <view class="month-box">
              <text class="month-text">{{ month || '请选择月份' }}</text>
              <text class="filter-arrow">▾</text>
            </view>
          </picker>
        </view>
        <button class="primary-btn" :loading="calculating" :disabled="calculating" @click="handleCalc">
          触发计算
        </button>
      </view>

      <!-- 计算结果卡片 -->
      <view v-if="result" class="card">
        <text class="card-title">计算结果（{{ result.month }}）</text>
        <view class="result-grid">
          <view class="result-item">
            <text class="result-num">{{ result.detailsCount ?? 0 }}</text>
            <text class="result-label">明细条数</text>
          </view>
          <view class="result-item">
            <text class="result-num">{{ result.teacherCount ?? 0 }}</text>
            <text class="result-label">涉及教师数</text>
          </view>
          <view class="result-item">
            <text class="result-num" :class="errors.length > 0 ? 'num-danger' : 'num-success'">
              {{ errors.length }}
            </text>
            <text class="result-label">异常条数</text>
          </view>
        </view>
      </view>

      <!-- 错误列表 -->
      <view v-if="errors.length > 0" class="card">
        <text class="card-title error-title">计算异常（{{ errors.length }}）</text>
        <view v-for="(err, idx) in errors" :key="idx" class="error-item">
          <text class="error-dot">●</text>
          <text class="error-text">{{ err }}</text>
        </view>
      </view>

      <!-- 规则校验入口 -->
      <button class="ghost-btn" @click="goValidate">前往规则校验</button>
    </template>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { post } from '../../utils/request'
import { canUseSalary } from '../../store/user'

// 权限控制：仅工资相关角色可用
const allowed = canUseSalary()

// 默认月份：当前月
const now = new Date()
const pad = (n) => String(n).padStart(2, '0')
const defaultMonth = now.getFullYear() + '-' + pad(now.getMonth() + 1)

const month = ref(defaultMonth)
const calculating = ref(false)
const result = ref(null)
const errors = ref([])

function onMonthChange(e) {
  month.value = e.detail.value
}

// POST /salary/calc/month?month=yyyy-MM
async function handleCalc() {
  if (!month.value) {
    uni.showToast({ title: '请先选择月份', icon: 'none' })
    return
  }
  uni.showModal({
    title: '触发计算',
    content: '确定重新计算 ' + month.value + ' 的全部教师工资吗？',
    success: async (res) => {
      if (!res.confirm) return
      calculating.value = true
      try {
        const data = await post('/salary/calc/month?month=' + month.value)
        result.value = data || {}
        errors.value = Array.isArray(data.errors) ? data.errors : []
        uni.showToast({ title: '计算完成', icon: 'success' })
      } catch (e) {
        // 错误提示已在 request 封装中统一处理
      } finally {
        calculating.value = false
      }
    }
  })
}

function goValidate() {
  uni.navigateTo({ url: '/pages/rule/validate' })
}
</script>

<style lang="scss" scoped>
.calc-page {
  min-height: 100vh;
  background-color: $bg-page;
  padding: 24rpx;
  box-sizing: border-box;
  padding-bottom: env(safe-area-inset-bottom);
}

.card {
  background-color: #ffffff;
  border-radius: $radius;
  padding: 32rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-title {
  display: block;
  font-size: 30rpx;
  font-weight: bold;
  color: $text-main;
}

.error-title {
  color: $danger;
}

.card-desc {
  display: block;
  margin-top: 12rpx;
  font-size: 24rpx;
  color: $text-grey;
  line-height: 38rpx;
}

.month-row {
  display: flex;
  align-items: center;
  margin-top: 32rpx;
  margin-bottom: 32rpx;
}

.month-label {
  width: 160rpx;
  font-size: 28rpx;
  color: $text-sub;
}

.month-picker {
  flex: 1;
}

.month-box {
  height: 80rpx;
  background-color: #f7f8fa;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24rpx;
}

.month-text {
  font-size: 28rpx;
  color: $text-main;
}

.filter-arrow {
  font-size: 22rpx;
  color: $text-grey;
}

.primary-btn {
  height: 88rpx;
  line-height: 88rpx;
  background-color: $primary;
  color: #ffffff;
  font-size: 30rpx;
  border-radius: 12rpx;

  &::after {
    border: none;
  }

  &[disabled] {
    opacity: 0.6;
    color: #ffffff;
    background-color: $primary;
  }
}

.ghost-btn {
  height: 88rpx;
  line-height: 88rpx;
  background-color: #ffffff;
  color: $primary;
  font-size: 30rpx;
  border-radius: $radius;
  border: 1rpx solid $primary;

  &::after {
    border: none;
  }
}

/* 结果统计 */
.result-grid {
  display: flex;
  margin-top: 32rpx;
}

.result-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.result-num {
  font-size: 44rpx;
  font-weight: bold;
  color: $primary;
}

.num-danger {
  color: $danger;
}

.num-success {
  color: $success;
}

.result-label {
  margin-top: 8rpx;
  font-size: 24rpx;
  color: $text-grey;
}

/* 错误列表 */
.error-item {
  display: flex;
  align-items: flex-start;
  background-color: $danger-bg;
  border-radius: 8rpx;
  padding: 16rpx 20rpx;
  margin-top: 16rpx;
}

.error-dot {
  font-size: 20rpx;
  color: $danger;
  margin-right: 12rpx;
  margin-top: 6rpx;
}

.error-text {
  flex: 1;
  font-size: 24rpx;
  color: $danger;
  line-height: 36rpx;
}

/* 无权限 */
.no-perm {
  padding: 120rpx 0;
  display: flex;
  justify-content: center;
}

.no-perm-text {
  font-size: 28rpx;
  color: $text-grey;
}
</style>
