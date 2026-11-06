<template>
  <view class="page">
    <view class="tip-card">
      <text class="tip-text">请如实填写本次课程考勤信息，提交后进入审核流程</text>
    </view>

    <!-- 结束打卡表单 -->
    <view class="form-card">
      <view class="form-item">
        <text class="form-label">实际到课人数</text>
        <input
          class="form-input"
          type="number"
          v-model="studentCount"
          placeholder="请输入实际到课人数"
          placeholder-class="input-placeholder"
        />
      </view>
      <view class="form-item">
        <text class="form-label">请假人数</text>
        <input
          class="form-input"
          type="number"
          v-model="leaveCount"
          placeholder="请输入请假人数"
          placeholder-class="input-placeholder"
        />
      </view>
      <view class="form-item">
        <view class="label-row">
          <text class="form-label">缺勤人数</text>
          <text class="label-extra">选填，留空由系统自动核算</text>
        </view>
        <input
          class="form-input"
          type="number"
          v-model="absentCount"
          placeholder="留空则由系统自动核算"
          placeholder-class="input-placeholder"
        />
      </view>
      <view class="form-item">
        <text class="form-label">实际时长（分钟）</text>
        <input
          class="form-input"
          type="number"
          v-model="durationMinutes"
          placeholder="请输入实际上课时长"
          placeholder-class="input-placeholder"
        />
      </view>
      <view class="form-item form-item-last">
        <text class="form-label">异常说明</text>
        <textarea
          class="form-textarea"
          v-model="exceptionNote"
          placeholder="如调课、设备故障、学生早退等情况说明（选填）"
          placeholder-class="input-placeholder"
        />
      </view>
    </view>

    <button class="submit-btn" :loading="submitting" :disabled="submitting" @click="handleSubmit">
      提交结束打卡
    </button>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { end as attendanceEnd } from '../../services/attendance'

const scheduleId = ref('')
const studentCount = ref('')
const leaveCount = ref('')
const absentCount = ref('')
const durationMinutes = ref('')
const exceptionNote = ref('')
const submitting = ref(false)

onLoad((query) => {
  scheduleId.value = query.scheduleId || ''
  // 实际时长默认取排课的预期时长
  durationMinutes.value = query.expectedDuration || ''
})

async function handleSubmit() {
  if (studentCount.value === '') {
    uni.showToast({ title: '请输入实际到课人数', icon: 'none' })
    return
  }
  if (durationMinutes.value === '') {
    uni.showToast({ title: '请输入实际时长', icon: 'none' })
    return
  }
  const student = Number(studentCount.value)
  const leave = Number(leaveCount.value || 0)
  const duration = Number(durationMinutes.value)
  if (student < 0 || leave < 0 || duration <= 0) {
    uni.showToast({ title: '请输入正确的数值', icon: 'none' })
    return
  }
  submitting.value = true
  try {
    const payload = {
      studentCount: student,
      leaveCount: leave,
      durationMinutes: duration
    }
    const note = exceptionNote.value.trim()
    if (note) {
      payload.exceptionNote = note
    }
    // 缺勤人数选填，填写时一并提交，未填由系统自动核算
    if (absentCount.value !== '') {
      payload.absentCount = Number(absentCount.value)
    }
    await attendanceEnd(scheduleId.value, payload)
    uni.showToast({ title: '本次打卡已结束', icon: 'success' })
    setTimeout(() => {
      uni.navigateBack()
    }, 800)
  } catch (e) {
    // 错误提示已在 request 封装中统一处理
  } finally {
    submitting.value = false
  }
}
</script>

<style lang="scss" scoped>
.page {
  padding: 24rpx;
}

.tip-card {
  background-color: $primary-light;
  border-radius: $radius;
  padding: 24rpx 28rpx;
  margin-bottom: 24rpx;
}

.tip-text {
  font-size: 26rpx;
  color: $primary;
  line-height: 1.6;
}

.form-card {
  background-color: $bg-card;
  border-radius: $radius;
  padding: 32rpx 28rpx;
}

.form-item {
  margin-bottom: 32rpx;

  &.form-item-last {
    margin-bottom: 0;
  }
}

.label-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.form-label {
  font-size: 28rpx;
  color: $text-main;
  font-weight: 500;
}

.label-extra {
  font-size: 22rpx;
  color: $text-grey;
}

.form-input {
  margin-top: 16rpx;
  height: 88rpx;
  background-color: #f7f8fa;
  border-radius: 12rpx;
  padding: 0 24rpx;
  font-size: 30rpx;
  color: $text-main;
}

.form-textarea {
  margin-top: 16rpx;
  width: 100%;
  height: 200rpx;
  background-color: #f7f8fa;
  border-radius: 12rpx;
  padding: 20rpx 24rpx;
  font-size: 28rpx;
  color: $text-main;
  box-sizing: border-box;
}

.submit-btn {
  margin-top: 40rpx;
  height: 88rpx;
  line-height: 88rpx;
  background-color: $primary;
  color: #ffffff;
  font-size: 32rpx;
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
</style>
