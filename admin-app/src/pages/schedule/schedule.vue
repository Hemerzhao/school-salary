<template>
  <view class="schedule-page">
    <!-- 筛选栏：教师 + 时间范围 -->
    <view class="filter-bar">
      <picker class="filter-picker" :range="teacherLabels" @change="onTeacherChange">
        <view class="filter-item">
          <text class="filter-text">{{ teacherLabels[teacherIndex] }}</text>
          <text class="filter-arrow">▾</text>
        </view>
      </picker>
      <picker class="filter-picker" :range="rangeLabels" @change="onRangeChange">
        <view class="filter-item">
          <text class="filter-text">{{ rangeLabels[rangeIndex] }}</text>
          <text class="filter-arrow">▾</text>
        </view>
      </picker>
    </view>

    <!-- 排课卡片列表（只读查看） -->
    <view class="list">
      <view v-for="item in records" :key="item.id" class="card">
        <view class="card-header">
          <text class="teacher">{{ teacherName(item.teacherId) }}</text>
          <text
            class="status-tag"
            :style="{ color: schedStatus(item.status).color, backgroundColor: schedStatus(item.status).bg }"
          >
            {{ schedStatus(item.status).text }}
          </text>
        </view>
        <view class="card-body">
          <view class="info-row">
            <text class="info-label">上课时间</text>
            <text class="info-value">{{ scheduleTimeText(item) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">类型</text>
            <text class="info-value">
              <text
                class="type-tag"
                :class="item.scheduleType === 'NORMAL' ? 'type-normal' : 'type-gray'"
              >
                {{ scheduleTypeText(item.scheduleType) }}
              </text>
            </text>
          </view>
          <view class="info-row">
            <text class="info-label">计划时长</text>
            <text class="info-value">{{ formatDuration(item.expectedDuration) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">排课编号</text>
            <text class="info-value">#{{ item.id }}（教师ID {{ item.teacherId }}）</text>
          </view>
        </view>
      </view>

      <view v-if="records.length === 0 && !loading" class="empty">
        <text class="empty-text">暂无排课记录</text>
      </view>
      <view v-if="loading" class="loading">
        <text class="loading-text">加载中...</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { get } from '../../utils/request'
import {
  formatTime,
  formatDateTime,
  formatDuration,
  scheduleTypeText,
  scheduleStatusInfo as schedStatus
} from '../../utils/format'

// ==================== 教师下拉 ====================
const teachers = ref([])

const teacherLabels = computed(() => {
  const list = ['全部教师'].concat(teachers.value.map((t) => t.name + '（ID ' + t.id + '）'))
  return list
})

const teacherIndex = ref(0)

// 根据 teacherId 取教师名（下拉数据加载后可映射）
function teacherName(teacherId) {
  const t = teachers.value.find((x) => x.id === teacherId)
  if (t) return t.name + '（ID ' + teacherId + '）'
  return '教师 #' + teacherId
}

// ==================== 时间范围 ====================
const rangeLabels = ['全部时间', '今天', '近7天', '近30天']
const rangeIndex = ref(0)

const records = ref([])
const loading = ref(false)

// 根据选中的时间范围生成 startFrom/startTo 参数（yyyy-MM-dd HH:mm:ss）
function buildRangeParams() {
  const params = {}
  if (rangeIndex.value === 0) return params
  const now = new Date()
  const fmt = (d) => {
    const pad = (n) => String(n).padStart(2, '0')
    return (
      d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds())
    )
  }
  if (rangeIndex.value === 1) {
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    params.startFrom = fmt(start)
    params.startTo = fmt(now)
  } else {
    const days = rangeIndex.value === 2 ? 7 : 30
    const start = new Date(now.getTime() - days * 24 * 3600 * 1000)
    start.setHours(0, 0, 0, 0)
    params.startFrom = fmt(start)
    params.startTo = fmt(now)
  }
  return params
}

// 排课时间展示：开始 ~ 结束
function scheduleTimeText(item) {
  let text = formatDateTime(item.startTime) || '-'
  if (item.endTime) {
    text += ' ~ ' + formatTime(item.endTime)
  }
  return text
}

// 加载教师下拉数据：GET /teacher/list
async function loadTeachers() {
  try {
    const list = await get('/teacher/list', { status: 1 })
    teachers.value = Array.isArray(list) ? list : []
  } catch (e) {
    // 教师下拉加载失败不阻塞排课列表
  }
}

// 加载排课列表（只读）：GET /schedule/list
async function loadList() {
  loading.value = true
  try {
    const params = {}
    if (teacherIndex.value > 0) {
      const t = teachers.value[teacherIndex.value - 1]
      if (t) params.teacherId = t.id
    }
    Object.assign(params, buildRangeParams())
    const list = await get('/schedule/list', params)
    records.value = Array.isArray(list) ? list : []
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    loading.value = false
  }
}

function reload() {
  loadList()
}

function onTeacherChange(e) {
  teacherIndex.value = Number(e.detail.value)
  reload()
}

function onRangeChange(e) {
  rangeIndex.value = Number(e.detail.value)
  reload()
}

onShow(() => {
  loadTeachers()
  reload()
})
</script>

<style lang="scss" scoped>
.schedule-page {
  min-height: 100vh;
  background-color: $bg-page;
  padding: 24rpx;
  box-sizing: border-box;
  padding-bottom: env(safe-area-inset-bottom);
}

.filter-bar {
  display: flex;
  gap: 20rpx;
  margin-bottom: 24rpx;
}

.filter-picker {
  flex: 1;
}

.filter-item {
  height: 72rpx;
  background-color: #ffffff;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24rpx;
}

.filter-text {
  font-size: 26rpx;
  color: $text-main;
}

.filter-arrow {
  font-size: 22rpx;
  color: $text-grey;
}

.card {
  background-color: #ffffff;
  border-radius: $radius;
  padding: 24rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16rpx;
}

.teacher {
  font-size: 30rpx;
  font-weight: bold;
  color: $text-main;
}

.status-tag {
  font-size: 22rpx;
  padding: 6rpx 16rpx;
  border-radius: 8rpx;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10rpx;
}

.info-label {
  font-size: 26rpx;
  color: $text-grey;
}

.info-value {
  font-size: 26rpx;
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
  background-color: #f5f5f5;
}

.empty,
.loading {
  padding: 48rpx 0;
  display: flex;
  justify-content: center;
}

.empty-text,
.loading-text {
  font-size: 26rpx;
  color: $text-grey;
}
</style>
