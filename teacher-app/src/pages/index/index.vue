<template>
  <view class="page">
    <!-- 顶部概览卡片 -->
    <view class="header-card">
      <view class="header-row">
        <text class="header-title">今日课程</text>
        <text class="header-date">{{ todayText }}</text>
      </view>
      <text class="header-count">共 {{ list.length }} 节课</text>
    </view>

    <view v-if="loading" class="empty-card">
      <text class="empty-text">加载中...</text>
    </view>

    <view v-else-if="list.length === 0" class="empty-card">
      <text class="empty-text">今天没有排课，好好休息吧～</text>
    </view>

    <template v-else>
      <view v-for="item in list" :key="item.id" class="course-card">
        <view class="card-top">
          <text class="course-time">{{ formatTime(item.startTime) }} - {{ formatTime(item.endTime) }}</text>
          <text class="type-tag" :class="scheduleTypeClass(item.scheduleType)">
            {{ scheduleTypeText(item.scheduleType) }}
          </text>
        </view>
        <view class="card-info">
          <text class="info-line">班级 ID：{{ item.classId }}</text>
          <text class="info-line">课程时长：{{ item.expectedDuration }} 分钟</text>
        </view>
        <view class="card-bottom">
          <!-- 无打卡记录且当前时间在排课时间 ±2 小时内：可开始打卡 -->
          <template v-if="!item.attendance">
            <button
              v-if="inStartWindow(item)"
              class="action-btn btn-primary"
              @click="handleStart(item)"
            >
              开始打卡
            </button>
            <text v-else class="status-text">未到打卡时间</text>
          </template>
          <!-- 已开始未结束：可结束打卡 -->
          <template v-else-if="!item.attendance.actualEndTime">
            <button class="action-btn btn-warning" @click="handleEnd(item)">结束打卡</button>
          </template>
          <!-- 已结束：显示审核状态 -->
          <template v-else>
            <text class="audit-tag" :class="'audit-' + item.attendance.auditStatus">
              {{ auditStatusText(item.attendance.auditStatus) }}
            </text>
          </template>
        </view>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import { listByTeacher } from '../../services/schedule'
import { start as attendanceStart, my as attendanceMy } from '../../services/attendance'
import { getUser } from '../../store/user'
import { formatTime, auditStatusText, scheduleTypeText, scheduleTypeClass } from '../../utils/format'

const list = ref([])
const loading = ref(true)
const todayText = ref('')

const weekNames = ['日', '一', '二', '三', '四', '五', '六']

function pad(n) {
  return n < 10 ? '0' + n : '' + n
}

function dateStr(d) {
  return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate())
}

function initToday() {
  const now = new Date()
  todayText.value = now.getMonth() + 1 + '月' + now.getDate() + '日 星期' + weekNames[now.getDay()]
}

// 当前时间在排课时间 ±2 小时内才允许开始打卡
function inStartWindow(item) {
  if (!item.startTime || !item.endTime) return false
  // iOS 不识别 'YYYY-MM-DD HH:mm:ss'，统一替换为 '/'
  const start = new Date(item.startTime.replace(/-/g, '/')).getTime()
  const end = new Date(item.endTime.replace(/-/g, '/')).getTime()
  const now = Date.now()
  const twoHours = 2 * 60 * 60 * 1000
  return now >= start - twoHours && now <= end + twoHours
}

async function loadData() {
  try {
    const user = getUser()
    if (!user || !user.teacherId) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    const now = new Date()
    const from = dateStr(now) + ' 00:00:00'
    const to = dateStr(now) + ' 23:59:59'
    const [schedules, records] = await Promise.all([
      listByTeacher(user.teacherId, from, to),
      attendanceMy()
    ])
    // 打卡记录按 scheduleId 建立映射，关联到当日排课
    const recordMap = {}
    ;(records || []).forEach((r) => {
      if (r && r.scheduleId != null && !recordMap[r.scheduleId]) {
        recordMap[r.scheduleId] = r
      }
    })
    list.value = (schedules || []).map((s) => ({ ...s, attendance: recordMap[s.id] || null }))
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    loading.value = false
  }
}

// 开始打卡：先尝试获取定位（失败不阻断流程），再调开始打卡接口
function handleStart(item) {
  uni.getLocation({
    type: 'gcj02',
    success: () => {
      // 定位成功，可在此扩展位置信息上报
    },
    fail: () => {
      // 定位失败不阻断打卡流程
      uni.showToast({ title: '定位失败，已继续打卡', icon: 'none' })
    },
    complete: async () => {
      try {
        await attendanceStart(item.id)
        uni.showToast({ title: '打卡成功', icon: 'success' })
        loadData()
      } catch (e) {
        // 错误提示已在 request 封装中统一处理
      }
    }
  })
}

// 结束打卡：跳转表单页
function handleEnd(item) {
  uni.navigateTo({
    url: '/pages/attendance/end?scheduleId=' + item.id + '&expectedDuration=' + (item.expectedDuration || '')
  })
}

onPullDownRefresh(async () => {
  await loadData()
  uni.stopPullDownRefresh()
})

onShow(() => {
  initToday()
  loadData()
})
</script>

<style lang="scss" scoped>
.page {
  padding: 24rpx;
}

.header-card {
  background-color: $primary;
  border-radius: $radius;
  padding: 32rpx;
  margin-bottom: 24rpx;
  display: flex;
  flex-direction: column;
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #ffffff;
}

.header-date {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
}

.header-count {
  margin-top: 12rpx;
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
}

.course-card,
.empty-card {
  background-color: $bg-card;
  border-radius: $radius;
  padding: 28rpx;
  margin-bottom: 24rpx;
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

.card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.course-time {
  font-size: 32rpx;
  font-weight: bold;
  color: $text-main;
}

.type-tag {
  font-size: 22rpx;
  padding: 4rpx 16rpx;
  border-radius: 8rpx;
}

.type-normal {
  color: $primary;
  background-color: $primary-light;
}

.type-gray {
  color: $text-grey;
  background-color: #f0f1f5;
}

.card-info {
  margin-top: 16rpx;
  display: flex;
  flex-direction: column;
}

.info-line {
  font-size: 26rpx;
  color: $text-sub;
  line-height: 1.8;
}

.card-bottom {
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid $border-color;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.action-btn {
  margin: 0;
  height: 64rpx;
  line-height: 64rpx;
  padding: 0 44rpx;
  font-size: 28rpx;
  color: #ffffff;
  border-radius: 32rpx;

  &::after {
    border: none;
  }
}

.btn-primary {
  background-color: $primary;
}

.btn-warning {
  background-color: $warning;
}

.status-text {
  font-size: 26rpx;
  color: $text-grey;
}

.audit-tag {
  font-size: 26rpx;
  padding: 8rpx 24rpx;
  border-radius: 8rpx;
}

.audit-0 {
  color: $warning;
  background-color: #fff7e6;
}

.audit-1 {
  color: $success;
  background-color: #f6ffed;
}

.audit-2 {
  color: $danger;
  background-color: #fff1f0;
}
</style>
