<template>
  <view class="page">
    <view v-if="loading" class="empty-card">
      <text class="empty-text">加载中...</text>
    </view>

    <template v-else>
      <!-- 本月工资卡片 -->
      <view v-if="current" class="month-card" @click="goDetail(current.id)">
        <view class="month-top">
          <text class="month-text">{{ current.month }} 工资单</text>
          <text class="month-status">{{ salaryStatusText(current.status) }}</text>
        </view>
        <text class="net-amount">¥ {{ formatMoney(current.netAmount) }}</text>
        <view class="sub-row">
          <text class="sub-text">应发 ¥{{ formatMoney(current.grossAmount) }}</text>
          <text class="sub-text">调整 ¥{{ formatMoney(current.adjustmentAmount) }}</text>
        </view>
        <text class="month-tip">点击查看工资单详情</text>
      </view>
      <view v-else class="empty-card">
        <text class="empty-text">暂无工资单数据</text>
      </view>

      <!-- 历史月份列表 -->
      <view class="section-title">
        <text>历史月份</text>
      </view>

      <view v-if="records.length === 0" class="empty-card">
        <text class="empty-text">暂无历史工资单</text>
      </view>
      <template v-else>
        <view
          v-for="item in records"
          :key="item.id"
          class="history-card"
          @click="goDetail(item.id)"
        >
          <view class="history-left">
            <text class="history-month">{{ item.month }}</text>
            <text class="history-gross">应发 ¥{{ formatMoney(item.grossAmount) }}</text>
          </view>
          <view class="history-right">
            <text class="history-net">¥ {{ formatMoney(item.netAmount) }}</text>
            <text class="history-status" :style="{ color: salaryStatusColor(item.status) }">
              {{ salaryStatusText(item.status) }}
            </text>
          </view>
        </view>
      </template>
    </template>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { statementList } from '../../services/salary'
import { getUser } from '../../store/user'
import { formatMoney, salaryStatusText, salaryStatusColor } from '../../utils/format'

const current = ref(null)
const records = ref([])
const loading = ref(true)

function pad(n) {
  return n < 10 ? '0' + n : '' + n
}

async function loadData() {
  try {
    const user = getUser()
    if (!user || !user.teacherId) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    const data = await statementList(user.teacherId, 1, 20)
    const list = (data && data.records) || []
    // 按月份倒序，最新的在前
    list.sort((a, b) => (a.month > b.month ? -1 : a.month < b.month ? 1 : 0))
    const now = new Date()
    const nowMonth = now.getFullYear() + '-' + pad(now.getMonth() + 1)
    // 优先展示本月工资单，没有则展示最近一份
    current.value = list.find((r) => r.month === nowMonth) || list[0] || null
    records.value = current.value ? list.filter((r) => r.id !== current.value.id) : list
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    loading.value = false
  }
}

function goDetail(id) {
  if (!id) return
  uni.navigateTo({ url: '/pages/salary/detail?id=' + id })
}

onShow(() => loadData())
</script>

<style lang="scss" scoped>
.page {
  padding: 24rpx;
}

.month-card {
  background: linear-gradient(135deg, $primary 0%, #4d94ff 100%);
  border-radius: $radius;
  padding: 36rpx 32rpx;
  margin-bottom: 24rpx;
  display: flex;
  flex-direction: column;
}

.month-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.month-text {
  font-size: 30rpx;
  color: rgba(255, 255, 255, 0.9);
}

.month-status {
  font-size: 22rpx;
  color: #ffffff;
  background-color: rgba(255, 255, 255, 0.2);
  padding: 4rpx 20rpx;
  border-radius: 24rpx;
}

.net-amount {
  margin-top: 24rpx;
  font-size: 64rpx;
  font-weight: bold;
  color: #ffffff;
}

.sub-row {
  margin-top: 16rpx;
  display: flex;
}

.sub-text {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
  margin-right: 40rpx;
}

.month-tip {
  margin-top: 24rpx;
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.65);
}

.section-title {
  padding: 8rpx 8rpx 16rpx;
  font-size: 28rpx;
  color: $text-sub;
}

.history-card,
.empty-card {
  background-color: $bg-card;
  border-radius: $radius;
  padding: 28rpx;
  margin-bottom: 20rpx;
}

.history-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

.history-month {
  display: block;
  font-size: 30rpx;
  font-weight: bold;
  color: $text-main;
}

.history-gross {
  display: block;
  margin-top: 8rpx;
  font-size: 24rpx;
  color: $text-grey;
}

.history-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.history-net {
  font-size: 34rpx;
  font-weight: bold;
  color: $text-main;
}

.history-status {
  margin-top: 8rpx;
  font-size: 22rpx;
}
</style>
