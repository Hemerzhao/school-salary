<template>
  <view class="page">
    <!-- 本周 / 本月 切换 -->
    <view class="tab-bar">
      <view class="tab-item" :class="{ active: mode === 'week' }" @click="switchMode('week')">
        <text>本周</text>
      </view>
      <view class="tab-item" :class="{ active: mode === 'month' }" @click="switchMode('month')">
        <text>本月</text>
      </view>
    </view>

    <view v-if="loading" class="empty-card">
      <text class="empty-text">加载中...</text>
    </view>

    <view v-else-if="groups.length === 0" class="empty-card">
      <text class="empty-text">该时段暂无排课</text>
    </view>

    <template v-else>
      <view v-for="group in groups" :key="group.date" class="date-group">
        <view class="date-header">
          <text class="date-text">{{ group.label }}</text>
          <text class="date-count">{{ group.items.length }} 节课</text>
        </view>
        <view v-for="item in group.items" :key="item.id" class="course-card">
          <view class="card-top">
            <text class="course-time">{{ formatTime(item.startTime) }} - {{ formatTime(item.endTime) }}</text>
            <text class="type-tag" :class="scheduleTypeClass(item.scheduleType)">
              {{ scheduleTypeText(item.scheduleType) }}
            </text>
          </view>
          <view class="card-info">
            <text class="info-line">班级 ID：{{ item.classId }}</text>
            <text class="info-line">课程 ID：{{ item.courseId }} · 时长 {{ item.expectedDuration }} 分钟</text>
          </view>
        </view>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listByTeacher } from '../../services/schedule'
import { getUser } from '../../store/user'
import { formatTime, scheduleTypeText, scheduleTypeClass } from '../../utils/format'

const mode = ref('week') // 'week' 本周 | 'month' 本月
const groups = ref([])
const loading = ref(true)

const weekNames = ['日', '一', '二', '三', '四', '五', '六']

function pad(n) {
  return n < 10 ? '0' + n : '' + n
}

function dateStr(d) {
  return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate())
}

// 计算当前选择的统计范围（周一为一周开始）
function getRange() {
  const now = new Date()
  let start
  let end
  if (mode.value === 'week') {
    const day = now.getDay() || 7
    start = new Date(now)
    start.setDate(now.getDate() - day + 1)
    end = new Date(start)
    end.setDate(start.getDate() + 6)
  } else {
    start = new Date(now.getFullYear(), now.getMonth(), 1)
    end = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  }
  start.setHours(0, 0, 0, 0)
  end.setHours(23, 59, 59, 999)
  return { start, end }
}

async function loadData() {
  try {
    const user = getUser()
    if (!user || !user.teacherId) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    const { start, end } = getRange()
    const list = await listByTeacher(
      user.teacherId,
      dateStr(start) + ' 00:00:00',
      dateStr(end) + ' 23:59:59'
    )
    // 按日期分组，组内按开始时间升序
    const map = {}
    ;(list || []).forEach((item) => {
      const key = (item.startTime || '').split(' ')[0]
      if (!key) return
      if (!map[key]) map[key] = []
      map[key].push(item)
    })
    groups.value = Object.keys(map)
      .sort()
      .map((key) => {
        const d = new Date(key.replace(/-/g, '/'))
        return {
          date: key,
          label: d.getMonth() + 1 + '月' + d.getDate() + '日 星期' + weekNames[d.getDay()],
          items: map[key].sort((a, b) => (a.startTime > b.startTime ? 1 : -1))
        }
      })
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    loading.value = false
  }
}

function switchMode(m) {
  if (mode.value === m) return
  mode.value = m
  loadData()
}

onShow(() => loadData())
</script>

<style lang="scss" scoped>
.page {
  padding: 24rpx;
}

.tab-bar {
  display: flex;
  background-color: $bg-card;
  border-radius: $radius;
  padding: 8rpx;
  margin-bottom: 24rpx;
}

.tab-item {
  flex: 1;
  text-align: center;
  height: 64rpx;
  line-height: 64rpx;
  font-size: 28rpx;
  color: $text-sub;
  border-radius: 12rpx;

  &.active {
    background-color: $primary;
    color: #ffffff;
    font-weight: 500;
  }
}

.date-group {
  margin-bottom: 8rpx;
}

.date-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8rpx 8rpx 16rpx;
}

.date-text {
  font-size: 30rpx;
  font-weight: bold;
  color: $text-main;
}

.date-count {
  font-size: 24rpx;
  color: $text-grey;
}

.course-card,
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
</style>
