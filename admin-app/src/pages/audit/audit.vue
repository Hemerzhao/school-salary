<template>
  <view class="audit-page">
    <!-- 筛选栏：操作动作 + 时间范围 -->
    <view class="filter-bar">
      <picker class="filter-picker" :range="actionLabels" @change="onActionChange">
        <view class="filter-item">
          <text class="filter-text">{{ actionLabels[actionIndex] }}</text>
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

    <!-- 审计日志列表 -->
    <view class="list">
      <view v-for="item in records" :key="item.id" class="card">
        <view class="card-header">
          <text class="operator">{{ item.operatorName || '未知操作人' }}</text>
          <text class="action-tag">{{ actionText(item.action) }}</text>
        </view>
        <view class="card-body">
          <view class="info-row">
            <text class="info-label">操作对象</text>
            <text class="info-value">{{ targetText(item) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">操作时间</text>
            <text class="info-value">{{ item.createdAt || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">客户端 IP</text>
            <text class="info-value">{{ item.clientIp || '-' }}</text>
          </view>
          <view v-if="item.remark" class="remark-row">
            <text class="remark-label">备注</text>
            <text class="remark-text">{{ item.remark }}</text>
          </view>
        </view>
      </view>

      <view v-if="records.length === 0 && !loading" class="empty">
        <text class="empty-text">暂无审计日志</text>
      </view>
      <view v-if="loading" class="loading">
        <text class="loading-text">加载中...</text>
      </view>
      <view v-else-if="records.length > 0 && finished" class="loading">
        <text class="loading-text">没有更多了</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onPullDownRefresh, onReachBottom } from '@dcloudio/uni-app'
import { get } from '../../utils/request'

// ==================== 筛选状态 ====================
// 操作动作筛选（'' 表示全部）
const actionLabels = ['全部动作', 'CREATE 创建', 'UPDATE 更新', 'PUBLISH 发布', 'LOCK 锁定', 'EXPORT 导出', 'CALC 计算']
const actionValues = ['', 'CREATE', 'UPDATE', 'PUBLISH', 'LOCK', 'EXPORT', 'CALC']
const actionIndex = ref(0)

const rangeLabels = ['全部时间', '今天', '近7天', '近30天']
const rangeIndex = ref(0)

// ==================== 列表状态 ====================
const records = ref([])
const page = ref(1)
const size = 10
const loading = ref(false)
const finished = ref(false)

// 动作展示：后端动作可能带前缀（如 AUDIT_APPROVE / MARK_PAID），原样展示更利于排查
function actionText(action) {
  return action || '-'
}

// 操作对象：类型 + 名称/ID
function targetText(item) {
  const type = item.targetType || '-'
  if (item.targetName) return type + ' · ' + item.targetName
  if (item.targetId != null) return type + ' #' + item.targetId
  return type
}

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

// GET /audit/log/list 分页查询
async function loadList(reset) {
  if (loading.value) return
  if (reset) {
    page.value = 1
    finished.value = false
  } else if (finished.value) {
    return
  }
  loading.value = true
  try {
    const params = { current: page.value, size }
    if (actionValues[actionIndex.value] !== '') params.action = actionValues[actionIndex.value]
    Object.assign(params, buildRangeParams())
    const data = await get('/audit/log/list', params)
    const list = data.records || []
    if (reset) {
      records.value = list
    } else {
      records.value = records.value.concat(list)
    }
    if (list.length < size) {
      finished.value = true
    } else {
      page.value += 1
    }
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    loading.value = false
  }
}

function reload() {
  loadList(true)
}

function onActionChange(e) {
  actionIndex.value = Number(e.detail.value)
  reload()
}

function onRangeChange(e) {
  rangeIndex.value = Number(e.detail.value)
  reload()
}

// 首次加载 + 下拉刷新 + 触底加载下一页
loadList(true)

onPullDownRefresh(() => {
  reload()
  setTimeout(() => uni.stopPullDownRefresh(), 800)
})

onReachBottom(() => {
  loadList(false)
})
</script>

<style lang="scss" scoped>
.audit-page {
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

.operator {
  font-size: 30rpx;
  font-weight: bold;
  color: $text-main;
}

.action-tag {
  font-size: 22rpx;
  color: $primary;
  background-color: $primary-light;
  padding: 6rpx 16rpx;
  border-radius: 8rpx;
}

.info-row {
  display: flex;
  justify-content: space-between;
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

.remark-row {
  background-color: #fafafa;
  border-radius: 8rpx;
  padding: 12rpx 20rpx;
  margin-top: 8rpx;
}

.remark-label {
  font-size: 24rpx;
  color: $text-grey;
  font-weight: 500;
}

.remark-text {
  display: block;
  margin-top: 4rpx;
  font-size: 24rpx;
  color: $text-sub;
  line-height: 36rpx;
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
