<template>
  <view class="attendance-page">
    <!-- 筛选栏：审核状态 + 时间范围 -->
    <view class="filter-bar">
      <picker class="filter-picker" :range="auditFilterLabels" @change="onAuditFilterChange">
        <view class="filter-item">
          <text class="filter-text">{{ auditFilterLabels[auditFilterIndex] }}</text>
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

    <!-- 打卡记录卡片列表 -->
    <view class="list">
      <view v-for="item in records" :key="item.id" class="card">
        <view class="card-header">
          <text class="teacher">教师 #{{ item.teacherId }}</text>
          <text
            class="status-tag"
            :style="{ color: auditInfo(item.auditStatus).color, backgroundColor: auditInfo(item.auditStatus).bg }"
          >
            {{ auditInfo(item.auditStatus).text }}
          </text>
        </view>
        <view class="card-body">
          <view class="info-row">
            <text class="info-label">打卡时间</text>
            <text class="info-value">{{ attendanceTimeText(item) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">时长</text>
            <text class="info-value">{{ formatDuration(item.durationMinutes) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">人数</text>
            <text class="info-value">
              到课 {{ item.studentCount ?? '-' }} / 请假 {{ item.leaveCount ?? 0 }} / 缺勤 {{ item.absentCount ?? 0 }}
            </text>
          </view>
          <view v-if="item.exceptionNote" class="exception-row">
            <text class="exception-label">异常说明</text>
            <text class="exception-text">{{ item.exceptionNote }}</text>
          </view>
          <view v-if="item.auditRemark" class="exception-row">
            <text class="exception-label">审核备注</text>
            <text class="exception-text">{{ item.auditRemark }}</text>
          </view>
          <view v-if="item.isMakeup === 1" class="makeup-tag">
            <text class="makeup-text">补卡</text>
          </view>
        </view>
        <!-- 待审核显示操作按钮 -->
        <view v-if="item.auditStatus === 0" class="card-actions">
          <button class="btn btn-pass" :disabled="acting" @click="onApprove(item)">通 过</button>
          <button class="btn btn-reject" :disabled="acting" @click="openReject(item)">驳 回</button>
        </view>
      </view>

      <!-- 空状态 / 加载状态 -->
      <view v-if="records.length === 0 && !loading" class="empty">
        <text class="empty-text">暂无打卡记录</text>
      </view>
      <view v-if="loading" class="loading">
        <text class="loading-text">加载中...</text>
      </view>
      <view v-else-if="records.length > 0 && finished" class="loading">
        <text class="loading-text">没有更多了</text>
      </view>
    </view>

    <!-- 驳回弹层（自定义简单弹层，带备注输入框） -->
    <view v-if="rejectVisible" class="mask" @click="closeReject">
      <view class="modal" @click.stop>
        <text class="modal-title">驳回打卡</text>
        <text class="modal-sub">打卡记录 #{{ rejectTarget.id }}（教师 #{{ rejectTarget.teacherId }}）</text>
        <input
          class="modal-input"
          v-model="rejectRemark"
          placeholder="请输入驳回原因（必填）"
          placeholder-class="input-placeholder"
        />
        <view class="modal-actions">
          <button class="btn btn-plain" @click="closeReject">取 消</button>
          <button class="btn btn-danger" :disabled="acting" @click="confirmReject">确认驳回</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onPullDownRefresh, onReachBottom } from '@dcloudio/uni-app'
import { get, post } from '../../utils/request'
import { formatTime, formatDateTime, formatDuration, auditStatusInfo as auditInfo } from '../../utils/format'

// 打卡时间展示：开始 ~ 结束（无结束时间只显示开始）
function attendanceTimeText(item) {
  let text = formatDateTime(item.actualStartTime) || '-'
  if (item.actualEndTime) {
    text += ' ~ ' + formatTime(item.actualEndTime)
  }
  return text
}

// ==================== 筛选状态 ====================
// 审核状态：'' 全部 / 0 待审核 / 1 已通过 / 2 已驳回
const auditFilterLabels = ['全部状态', '待审核', '已通过', '已驳回']
const auditFilterValues = ['', 0, 1, 2]
const auditFilterIndex = ref(0)

// 时间范围：今天 / 近7天 / 近30天 / 全部
const rangeLabels = ['全部时间', '今天', '近7天', '近30天']
const rangeIndex = ref(0)

// ==================== 列表状态 ====================
const records = ref([])
const total = ref(0)
const page = ref(1)
const size = 10
const loading = ref(false)
const finished = ref(false)
const acting = ref(false)

// ==================== 驳回弹层 ====================
const rejectVisible = ref(false)
const rejectTarget = ref({})
const rejectRemark = ref('')

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

// 加载打卡分页数据：GET /attendance/list
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
    if (auditFilterValues[auditFilterIndex.value] !== '') {
      params.auditStatus = auditFilterValues[auditFilterIndex.value]
    }
    Object.assign(params, buildRangeParams())
    const data = await get('/attendance/list', params)
    const list = data.records || []
    total.value = data.total || 0
    if (reset) {
      records.value = list
    } else {
      records.value = records.value.concat(list)
    }
    // 不足一页说明已经到底
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

function onAuditFilterChange(e) {
  auditFilterIndex.value = Number(e.detail.value)
  reload()
}

function onRangeChange(e) {
  rangeIndex.value = Number(e.detail.value)
  reload()
}

// ==================== 审核操作 ====================
// 通过：直接调接口
function onApprove(item) {
  uni.showModal({
    title: '通过打卡',
    content: '确定通过教师 #' + item.teacherId + ' 的这条打卡吗？',
    success: (res) => {
      if (res.confirm) doAudit(item.id, 'APPROVE', '')
    }
  })
}

// 驳回：打开自定义弹层填写备注
function openReject(item) {
  rejectTarget.value = item
  rejectRemark.value = ''
  rejectVisible.value = true
}

function closeReject() {
  rejectVisible.value = false
  rejectTarget.value = {}
  rejectRemark.value = ''
}

function confirmReject() {
  if (!rejectRemark.value.trim()) {
    uni.showToast({ title: '请填写驳回原因', icon: 'none' })
    return
  }
  doAudit(rejectTarget.value.id, 'REJECT', rejectRemark.value.trim())
}

// POST /attendance/audit/{id} body { action, remark }
async function doAudit(id, action, remark) {
  acting.value = true
  try {
    await post('/attendance/audit/' + id, { action, remark })
    uni.showToast({ title: action === 'APPROVE' ? '已通过' : '已驳回', icon: 'success' })
    closeReject()
    reload()
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    acting.value = false
  }
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
.attendance-page {
  min-height: 100vh;
  background-color: $bg-page;
  padding: 24rpx;
  box-sizing: border-box;
  padding-bottom: env(safe-area-inset-bottom);
}

/* 筛选栏 */
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

/* 卡片 */
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

.exception-row {
  background-color: $warning-bg;
  border-radius: 8rpx;
  padding: 12rpx 20rpx;
  margin-top: 8rpx;
}

.exception-label {
  font-size: 24rpx;
  color: $warning;
  font-weight: 500;
}

.exception-text {
  display: block;
  margin-top: 4rpx;
  font-size: 24rpx;
  color: $text-sub;
  line-height: 36rpx;
}

.makeup-tag {
  margin-top: 8rpx;
}

.makeup-text {
  font-size: 22rpx;
  color: $primary;
  background-color: $primary-light;
  padding: 4rpx 16rpx;
  border-radius: 8rpx;
}

/* 操作按钮 */
.card-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 20rpx;
}

.btn {
  flex: 1;
  height: 72rpx;
  line-height: 72rpx;
  font-size: 28rpx;
  border-radius: 12rpx;
  margin: 0;

  &::after {
    border: none;
  }

  &[disabled] {
    opacity: 0.6;
  }
}

.btn-pass {
  background-color: $success;
  color: #ffffff;
}

.btn-reject {
  background-color: #ffffff;
  color: $danger;
  border: 1rpx solid $danger;
}

/* 空状态与加载 */
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

/* 驳回弹层 */
.mask {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;
}

.modal {
  width: 600rpx;
  background-color: #ffffff;
  border-radius: $radius;
  padding: 40rpx 32rpx;
}

.modal-title {
  display: block;
  font-size: 32rpx;
  font-weight: bold;
  color: $text-main;
}

.modal-sub {
  display: block;
  margin-top: 8rpx;
  font-size: 24rpx;
  color: $text-grey;
}

.modal-input {
  margin-top: 32rpx;
  height: 88rpx;
  background-color: #f7f8fa;
  border-radius: 12rpx;
  padding: 0 24rpx;
  font-size: 28rpx;
  color: $text-main;
}

.modal-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 40rpx;
}

.btn-plain {
  background-color: #f5f5f7;
  color: $text-sub;
}

.btn-danger {
  background-color: $danger;
  color: #ffffff;
}
</style>
