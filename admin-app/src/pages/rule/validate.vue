<template>
  <view class="validate-page">
    <!-- 权限提示 -->
    <view v-if="!allowed" class="no-perm">
      <text class="no-perm-text">当前角色无权使用规则校验</text>
    </view>

    <template v-else>
      <!-- 月份选择 + 校验按钮 -->
      <view class="card">
        <text class="card-title">规则异常校验</text>
        <text class="card-desc">扫描指定月份内全部教师的规则绑定情况，检查未绑定、区间重叠、版本未发布等问题</text>
        <view class="month-row">
          <text class="month-label">校验月份</text>
          <picker class="month-picker" mode="date" fields="month" :value="month" @change="onMonthChange">
            <view class="month-box">
              <text class="month-text">{{ month || '请选择月份' }}</text>
              <text class="filter-arrow">▾</text>
            </view>
          </picker>
        </view>
        <button class="primary-btn" :loading="checking" :disabled="checking" @click="handleValidate">
          校 验
        </button>
      </view>

      <!-- 校验通过 -->
      <view v-if="checked && errors.length === 0" class="pass-card">
        <text class="pass-icon">✔</text>
        <text class="pass-text">校验通过，{{ month }} 未发现规则异常</text>
      </view>

      <!-- 错误列表 -->
      <view v-if="errors.length > 0" class="card">
        <text class="card-title error-title">发现异常（{{ errors.length }}）</text>
        <view v-for="(item, idx) in errors" :key="idx" class="error-card">
          <view class="error-header">
            <text class="error-teacher">{{ item.teacherName }}（ID {{ item.teacherId }}）</text>
            <text class="error-type">{{ item.type }}</text>
          </view>
          <text class="error-message">{{ item.message }}</text>
        </view>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { get } from '../../utils/request'
import { canUseSalary } from '../../store/user'

// 权限控制：工资相关角色可用
const allowed = canUseSalary()

// 默认月份：当前月
const now = new Date()
const pad = (n) => String(n).padStart(2, '0')
const month = ref(now.getFullYear() + '-' + pad(now.getMonth() + 1))

const checking = ref(false)
const checked = ref(false)
const errors = ref([])

function onMonthChange(e) {
  month.value = e.detail.value
}

// GET /rule/validate?month=yyyy-MM → [{ teacherId, teacherName, type, message }]
async function handleValidate() {
  if (!month.value) {
    uni.showToast({ title: '请先选择月份', icon: 'none' })
    return
  }
  checking.value = true
  try {
    const list = await get('/rule/validate', { month: month.value })
    errors.value = Array.isArray(list) ? list : []
    checked.value = true
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    checking.value = false
  }
}
</script>

<style lang="scss" scoped>
.validate-page {
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

/* 校验通过卡片 */
.pass-card {
  background-color: $success-bg;
  border-radius: $radius;
  padding: 48rpx 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.pass-icon {
  font-size: 64rpx;
  color: $success;
  font-weight: bold;
}

.pass-text {
  margin-top: 20rpx;
  font-size: 28rpx;
  color: $success;
  font-weight: 500;
}

/* 错误卡片 */
.error-card {
  background-color: $danger-bg;
  border-radius: 12rpx;
  padding: 20rpx;
  margin-top: 16rpx;
}

.error-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.error-teacher {
  font-size: 28rpx;
  font-weight: 500;
  color: $danger;
}

.error-type {
  font-size: 22rpx;
  color: $danger;
  background-color: rgba(245, 34, 45, 0.1);
  padding: 4rpx 16rpx;
  border-radius: 8rpx;
}

.error-message {
  display: block;
  margin-top: 12rpx;
  font-size: 24rpx;
  color: $text-sub;
  line-height: 36rpx;
}

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
