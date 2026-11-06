<template>
  <view class="statement-page">
    <!-- 权限提示 -->
    <view v-if="!allowed" class="no-perm">
      <text class="no-perm-text">当前角色无权查看工资单</text>
    </view>

    <template v-else>
      <!-- 筛选栏：月份 + 状态 -->
      <view class="filter-bar">
        <picker class="filter-picker" mode="date" fields="month" :value="filterMonth" @change="onMonthChange">
          <view class="filter-item">
            <text class="filter-text">{{ filterMonth || '全部月份' }}</text>
            <text class="filter-arrow">▾</text>
          </view>
        </picker>
        <picker class="filter-picker" :range="statusLabels" @change="onStatusChange">
          <view class="filter-item">
            <text class="filter-text">{{ statusLabels[statusIndex] }}</text>
            <text class="filter-arrow">▾</text>
          </view>
        </picker>
      </view>
      <view v-if="filterMonth" class="clear-row" @click="clearMonth">
        <text class="clear-text">清除月份筛选</text>
      </view>

      <!-- 工资单卡片列表 -->
      <view class="list">
        <view
          v-for="item in records"
          :key="item.id"
          class="card"
          hover-class="card-hover"
          @click="goDetail(item.id)"
        >
          <view class="card-header">
            <text class="teacher">教师 #{{ item.teacherId }}</text>
            <text
              class="status-tag"
              :style="{ color: statusInfo(item.status).color, backgroundColor: statusInfo(item.status).bg }"
            >
              {{ statusInfo(item.status).text }}
            </text>
          </view>
          <view class="card-body">
            <view class="info-row">
              <text class="info-label">结算月份</text>
              <text class="info-value">{{ item.month }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">应发</text>
              <text class="info-value money">￥{{ formatMoney(item.grossAmount) }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">调整</text>
              <text class="info-value money" :class="Number(item.adjustmentAmount) < 0 ? 'money-minus' : ''">
                ￥{{ formatMoney(item.adjustmentAmount) }}
              </text>
            </view>
            <view class="info-row">
              <text class="info-label">实发</text>
              <text class="info-value money net">￥{{ formatMoney(item.netAmount) }}</text>
            </view>
          </view>
          <!-- 按角色与状态显示操作按钮 -->
          <view v-if="actionsOf(item).length > 0" class="card-actions" @click.stop>
            <button
              v-for="act in actionsOf(item)"
              :key="act.key"
              class="btn"
              :class="'btn-' + act.key"
              :disabled="acting"
              @click="act.run(item)"
            >
              {{ act.label }}
            </button>
          </view>
        </view>

        <view v-if="records.length === 0 && !loading" class="empty">
          <text class="empty-text">暂无工资单数据</text>
        </view>
        <view v-if="loading" class="loading">
          <text class="loading-text">加载中...</text>
        </view>
        <view v-else-if="records.length > 0 && finished" class="loading">
          <text class="loading-text">没有更多了</text>
        </view>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onPullDownRefresh, onReachBottom, onShow } from '@dcloudio/uni-app'
import { get, post } from '../../utils/request'
import { formatMoney, salaryStatusInfo as statusInfo } from '../../utils/format'
import { hasRole, canUseSalary, isSuperAdmin } from '../../store/user'

// 权限控制：工资相关角色可用
const allowed = canUseSalary()

// ==================== 筛选状态 ====================
const filterMonth = ref('')
const statusLabels = ['全部状态', '草稿', '已确认', '已锁定', '已发放']
const statusValues = ['', 0, 1, 2, 3]
const statusIndex = ref(0)

// ==================== 列表状态 ====================
const records = ref([])
const page = ref(1)
const size = 10
const loading = ref(false)
const finished = ref(false)
const acting = ref(false)

// GET /salary/statement/list
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
    if (filterMonth.value) params.month = filterMonth.value
    if (statusValues[statusIndex.value] !== '') params.status = statusValues[statusIndex.value]
    const data = await get('/salary/statement/list', params)
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

function onMonthChange(e) {
  filterMonth.value = e.detail.value
  reload()
}

function clearMonth() {
  filterMonth.value = ''
  reload()
}

function onStatusChange(e) {
  statusIndex.value = Number(e.detail.value)
  reload()
}

// ==================== 操作按钮 ====================
// 根据角色与状态返回当前卡片可用操作
function actionsOf(item) {
  const actions = []
  // 确认：草稿 且 财务 / 超管
  if (item.status === 0 && hasRole('FINANCE', 'SUPER_ADMIN')) {
    actions.push({ key: 'confirm', label: '确认', run: (it) => doAction('/salary/statement/' + it.id + '/confirm', '已确认') })
  }
  // 锁定：已确认，工资相关角色
  if (item.status === 1 && canUseSalary()) {
    actions.push({ key: 'lock', label: '锁定', run: (it) => doAction('/salary/statement/' + it.id + '/lock', '已锁定') })
  }
  // 标记已发放：已锁定，工资相关角色
  if (item.status === 2 && canUseSalary()) {
    actions.push({ key: 'paid', label: '标记已发放', run: (it) => doAction('/salary/statement/' + it.id + '/mark-paid', '已发放') })
  }
  // 解锁：仅超管，仅已锁定状态
  if (item.status === 2 && isSuperAdmin()) {
    actions.push({ key: 'unlock', label: '解锁', run: (it) => doAction('/salary/statement/' + it.id + '/unlock', '已解锁') })
  }
  return actions
}

// 统一操作确认弹窗 + POST 接口
function doAction(url, successText) {
  uni.showModal({
    title: '操作确认',
    content: '确定执行「' + successText + '」操作吗？',
    success: async (res) => {
      if (!res.confirm) return
      acting.value = true
      try {
        await post(url)
        uni.showToast({ title: successText, icon: 'success' })
        reload()
      } catch (e) {
        // 错误提示已在 request 封装中统一处理
      } finally {
        acting.value = false
      }
    }
  })
}

function goDetail(id) {
  uni.navigateTo({ url: '/pages/salary/detail?id=' + id })
}

// 首次加载由 onShow 触发（onShow 在首次进入与从详情页返回时都会执行），下拉刷新 + 触底加载
onShow(() => {
  if (allowed) reload()
})

onPullDownRefresh(() => {
  reload()
  setTimeout(() => uni.stopPullDownRefresh(), 800)
})

onReachBottom(() => {
  loadList(false)
})
</script>

<style lang="scss" scoped>
.statement-page {
  min-height: 100vh;
  background-color: $bg-page;
  padding: 24rpx;
  box-sizing: border-box;
  padding-bottom: env(safe-area-inset-bottom);
}

.filter-bar {
  display: flex;
  gap: 20rpx;
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

.clear-row {
  display: flex;
  justify-content: flex-end;
  padding: 12rpx 8rpx;
}

.clear-text {
  font-size: 24rpx;
  color: $primary;
}

.card {
  background-color: #ffffff;
  border-radius: $radius;
  padding: 24rpx;
  margin-bottom: 20rpx;
  margin-top: 8rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-hover {
  opacity: 0.85;
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

.money {
  color: $text-main;
}

.money-minus {
  color: $danger;
}

.net {
  font-size: 30rpx;
  font-weight: bold;
  color: $primary;
}

.card-actions {
  display: flex;
  gap: 16rpx;
  margin-top: 20rpx;
  flex-wrap: wrap;
}

.btn {
  flex: 1;
  min-width: 180rpx;
  height: 68rpx;
  line-height: 68rpx;
  font-size: 26rpx;
  border-radius: 12rpx;
  margin: 0;

  &::after {
    border: none;
  }

  &[disabled] {
    opacity: 0.6;
  }
}

.btn-confirm {
  background-color: $primary;
  color: #ffffff;
}

.btn-lock {
  background-color: $warning;
  color: #ffffff;
}

.btn-paid {
  background-color: $success;
  color: #ffffff;
}

.btn-unlock {
  background-color: #ffffff;
  color: $danger;
  border: 1rpx solid $danger;
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
