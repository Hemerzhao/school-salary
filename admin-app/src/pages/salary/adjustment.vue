<template>
  <view class="adjustment-page">
    <!-- 权限提示 -->
    <view v-if="!allowed" class="no-perm">
      <text class="no-perm-text">当前角色无权使用调整项</text>
    </view>

    <template v-else>
      <!-- 创建调整项表单 -->
      <view class="card">
        <text class="card-title">创建调整项</text>
        <view class="form-item">
          <text class="form-label">教师</text>
          <picker class="form-picker" :range="teacherLabels" @change="onTeacherChange">
            <view class="form-box">
              <text class="form-text" :class="{ placeholder: formTeacherIndex < 0 }">
                {{ formTeacherIndex < 0 ? '请选择教师' : teacherLabels[formTeacherIndex] }}
              </text>
              <text class="filter-arrow">▾</text>
            </view>
          </picker>
        </view>
        <view class="form-item">
          <text class="form-label">月份</text>
          <picker class="form-picker" mode="date" fields="month" :value="formMonth" @change="onFormMonthChange">
            <view class="form-box">
              <text class="form-text">{{ formMonth || '请选择月份' }}</text>
              <text class="filter-arrow">▾</text>
            </view>
          </picker>
        </view>
        <view class="form-item">
          <text class="form-label">类型</text>
          <picker class="form-picker" :range="typeLabels" @change="onTypeChange">
            <view class="form-box">
              <text class="form-text">{{ typeLabels[typeIndex] }}</text>
              <text class="filter-arrow">▾</text>
            </view>
          </picker>
        </view>
        <view class="form-item">
          <text class="form-label">金额（元）</text>
          <input
            class="form-input"
            v-model="formAmount"
            type="digit"
            placeholder="请输入金额，扣款请输入负数如 -200"
            placeholder-class="input-placeholder"
          />
        </view>
        <view class="form-item">
          <text class="form-label">原因</text>
          <textarea
            class="form-textarea"
            v-model="formReason"
            placeholder="请输入调整原因（必填）"
            placeholder-class="input-placeholder"
            maxlength="200"
          />
        </view>
        <button class="primary-btn" :loading="submitting" :disabled="submitting" @click="handleSubmit">
          提交创建
        </button>
      </view>

      <!-- 查询教师当月调整项 -->
      <view class="card">
        <text class="card-title">查询调整项</text>
        <text class="card-desc">选择教师与月份，查询其当月工资单关联的调整项</text>
        <view class="query-row">
          <picker class="query-picker" :range="teacherLabels" @change="onQueryTeacherChange">
            <view class="form-box">
              <text class="form-text" :class="{ placeholder: queryTeacherIndex < 0 }">
                {{ queryTeacherIndex < 0 ? '选择教师' : teacherLabels[queryTeacherIndex] }}
              </text>
              <text class="filter-arrow">▾</text>
            </view>
          </picker>
          <picker class="query-picker" mode="date" fields="month" :value="queryMonth" @change="onQueryMonthChange">
            <view class="form-box">
              <text class="form-text">{{ queryMonth }}</text>
              <text class="filter-arrow">▾</text>
            </view>
          </picker>
        </view>
        <button class="ghost-btn" :loading="querying" :disabled="querying" @click="handleQuery">查 询</button>

        <!-- 查询结果：调整项列表 -->
        <view v-if="queryStatementId" class="result-area">
          <text class="result-title">工资单 #{{ queryStatementId }}（{{ queryMonth }}）的调整项</text>
          <view v-if="queryAdjustments.length === 0" class="empty">
            <text class="empty-text">该工资单暂无调整项</text>
          </view>
          <view v-for="item in queryAdjustments" :key="item.id" class="adjust-item">
            <view class="adjust-header">
              <text class="adjust-type">{{ item.adjustType }}</text>
              <text
                class="adjust-status"
                :style="{ color: item.status === 1 ? successColor : greyColor, backgroundColor: item.status === 1 ? successBg : greyBg }"
              >
                {{ adjustStatusText(item.status) }}
              </text>
            </view>
            <text class="adjust-amount" :class="Number(item.amount) < 0 ? 'amount-danger' : ''">
              金额：￥{{ formatMoney(item.amount) }}
            </text>
            <text class="adjust-reason">原因：{{ item.reason || '-' }}</text>
            <button
              v-if="item.status === 0"
              class="confirm-btn"
              :disabled="confirming"
              @click="handleConfirm(item)"
            >
              确认
            </button>
          </view>
        </view>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { get, post } from '../../utils/request'
import { formatMoney, adjustStatusText } from '../../utils/format'
import { canUseSalary } from '../../store/user'

// 权限控制：工资相关角色可用
const allowed = canUseSalary()

// 状态色常量（调整项状态 tag 用）
const successColor = '#52c41a'
const successBg = '#f6ffed'
const greyColor = '#999999'
const greyBg = '#f5f5f5'

// ==================== 教师数据 ====================
const teachers = ref([])

const teacherLabels = computed(() => teachers.value.map((t) => t.name + '（ID ' + t.id + '）'))

async function loadTeachers() {
  try {
    const list = await get('/teacher/list', { status: 1 })
    teachers.value = Array.isArray(list) ? list : []
  } catch (e) {
    // 教师下拉加载失败不阻塞页面
  }
}

// ==================== 默认月份 ====================
const now = new Date()
const pad = (n) => String(n).padStart(2, '0')
const defaultMonth = now.getFullYear() + '-' + pad(now.getMonth() + 1)

// ==================== 创建表单 ====================
const formTeacherIndex = ref(-1)
const formMonth = ref(defaultMonth)
const typeLabels = ['补发', '扣款', '奖金', '其他']
const typeIndex = ref(0)
const formAmount = ref('')
const formReason = ref('')
const submitting = ref(false)

function onTeacherChange(e) {
  formTeacherIndex.value = Number(e.detail.value)
}

function onFormMonthChange(e) {
  formMonth.value = e.detail.value
}

function onTypeChange(e) {
  typeIndex.value = Number(e.detail.value)
}

// POST /salary/adjustment body { teacherId, month, adjustType, amount, reason }
async function handleSubmit() {
  const teacher = teachers.value[formTeacherIndex.value]
  if (!teacher) {
    uni.showToast({ title: '请选择教师', icon: 'none' })
    return
  }
  if (!formMonth.value) {
    uni.showToast({ title: '请选择月份', icon: 'none' })
    return
  }
  const amount = Number(formAmount.value)
  if (formAmount.value === '' || isNaN(amount)) {
    uni.showToast({ title: '请输入正确的金额', icon: 'none' })
    return
  }
  if (!formReason.value.trim()) {
    uni.showToast({ title: '请输入调整原因', icon: 'none' })
    return
  }
  submitting.value = true
  try {
    await post('/salary/adjustment', {
      teacherId: teacher.id,
      month: formMonth.value,
      adjustType: typeLabels[typeIndex.value],
      amount: amount,
      reason: formReason.value.trim()
    })
    uni.showToast({ title: '创建成功', icon: 'success' })
    // 清空表单
    formTeacherIndex.value = -1
    formAmount.value = ''
    formReason.value = ''
    // 若查询区正好是同教师同月份，自动刷新查询结果
    if (queryTeacherIndex.value >= 0 && queryMonth.value === formMonth.value) {
      handleQuery()
    }
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    submitting.value = false
  }
}

// ==================== 查询调整项 ====================
const queryTeacherIndex = ref(-1)
const queryMonth = ref(defaultMonth)
const querying = ref(false)
const confirming = ref(false)
const queryStatementId = ref(null)
const queryAdjustments = ref([])

function onQueryTeacherChange(e) {
  queryTeacherIndex.value = Number(e.detail.value)
}

function onQueryMonthChange(e) {
  queryMonth.value = e.detail.value
}

// 查询流程：先按教师+月份查工资单列表，再取其详情中的调整项
async function handleQuery() {
  const teacher = teachers.value[queryTeacherIndex.value]
  if (!teacher) {
    uni.showToast({ title: '请选择教师', icon: 'none' })
    return
  }
  querying.value = true
  try {
    // GET /salary/statement/list?teacherId=&month=
    const data = await get('/salary/statement/list', { teacherId: teacher.id, month: queryMonth.value, current: 1, size: 1 })
    const list = data.records || []
    if (list.length === 0) {
      queryStatementId.value = null
      queryAdjustments.value = []
      uni.showToast({ title: '该教师当月暂无工资单', icon: 'none' })
      return
    }
    // GET /salary/statement/{id}
    const detail = await get('/salary/statement/' + list[0].id)
    queryStatementId.value = list[0].id
    queryAdjustments.value = Array.isArray(detail.adjustments) ? detail.adjustments : []
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    querying.value = false
  }
}

// POST /salary/adjustment/{id}/confirm：确认调整项并重算实发
function handleConfirm(item) {
  uni.showModal({
    title: '确认调整项',
    content: '确定确认该调整项吗？确认后将重算工资单实发金额。',
    success: async (res) => {
      if (!res.confirm) return
      confirming.value = true
      try {
        await post('/salary/adjustment/' + item.id + '/confirm')
        uni.showToast({ title: '已确认', icon: 'success' })
        handleQuery()
      } catch (e) {
        // 错误提示已在 request 封装中统一处理
      } finally {
        confirming.value = false
      }
    }
  })
}

onShow(() => {
  if (allowed) loadTeachers()
})
</script>

<style lang="scss" scoped>
.adjustment-page {
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

.card-desc {
  display: block;
  margin-top: 8rpx;
  font-size: 24rpx;
  color: $text-grey;
}

/* 表单 */
.form-item {
  margin-top: 28rpx;
}

.form-label {
  display: block;
  font-size: 26rpx;
  color: $text-sub;
}

.form-picker {
  display: block;
  margin-top: 12rpx;
}

.form-box {
  height: 80rpx;
  background-color: #f7f8fa;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24rpx;
}

.form-text {
  font-size: 28rpx;
  color: $text-main;
}

.placeholder {
  color: #999999;
}

.filter-arrow {
  font-size: 22rpx;
  color: $text-grey;
}

.form-input {
  margin-top: 12rpx;
  height: 80rpx;
  background-color: #f7f8fa;
  border-radius: 12rpx;
  padding: 0 24rpx;
  font-size: 28rpx;
  color: $text-main;
}

.form-textarea {
  margin-top: 12rpx;
  width: 100%;
  min-height: 160rpx;
  background-color: #f7f8fa;
  border-radius: 12rpx;
  padding: 20rpx 24rpx;
  font-size: 28rpx;
  color: $text-main;
  box-sizing: border-box;
}

.primary-btn {
  margin-top: 40rpx;
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
  margin-top: 28rpx;
  height: 80rpx;
  line-height: 80rpx;
  background-color: #ffffff;
  color: $primary;
  font-size: 28rpx;
  border-radius: 12rpx;
  border: 1rpx solid $primary;

  &::after {
    border: none;
  }

  &[disabled] {
    opacity: 0.6;
    color: $primary;
  }
}

/* 查询区 */
.query-row {
  display: flex;
  gap: 20rpx;
  margin-top: 28rpx;
}

.query-picker {
  flex: 1;
}

.result-area {
  margin-top: 32rpx;
  border-top: 1rpx solid $border-color;
  padding-top: 24rpx;
}

.result-title {
  display: block;
  font-size: 26rpx;
  font-weight: 500;
  color: $text-sub;
}

/* 调整项 */
.adjust-item {
  background-color: #fafafa;
  border-radius: 12rpx;
  padding: 20rpx;
  margin-top: 16rpx;
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

.adjust-amount {
  display: block;
  margin-top: 10rpx;
  font-size: 26rpx;
  color: $text-main;
}

.amount-danger {
  color: $danger;
}

.adjust-reason {
  display: block;
  margin-top: 6rpx;
  font-size: 24rpx;
  color: $text-grey;
  line-height: 36rpx;
}

.confirm-btn {
  margin-top: 16rpx;
  height: 64rpx;
  line-height: 64rpx;
  background-color: $primary;
  color: #ffffff;
  font-size: 26rpx;
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

.empty {
  padding: 40rpx 0;
  display: flex;
  justify-content: center;
}

.empty-text {
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
