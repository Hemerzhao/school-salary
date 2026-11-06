<template>
  <view class="me-page">
    <!-- 用户信息卡 -->
    <view class="user-card">
      <view class="avatar">
        <text class="avatar-text">{{ avatarChar }}</text>
      </view>
      <view class="user-info">
        <text class="user-name">{{ user.name || user.username || '未登录' }}</text>
        <text class="user-account">账号：{{ user.username || '-' }}</text>
      </view>
      <text class="role-tag" :style="{ color: roleInfo.color, backgroundColor: roleInfo.bg }">
        {{ roleInfo.text }}
      </text>
    </view>

    <!-- 信息明细 -->
    <view class="info-card">
      <view class="info-row">
        <text class="info-label">用户ID</text>
        <text class="info-value">{{ user.id ?? '-' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">所属校区ID</text>
        <text class="info-value">{{ user.campusId ?? '全部校区' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">角色标识</text>
        <text class="info-value">{{ user.role || '-' }}</text>
      </view>
    </view>

    <!-- 退出登录 -->
    <button class="logout-btn" @click="handleLogout">退出登录</button>

    <text class="version-text">工资管理端 v1.0.0</text>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getUser, clear } from '../../store/user'
import { roleText, roleMap } from '../../utils/format'

const user = ref(getUser() || {})

const roleInfo = computed(() => roleMap[user.value.role] || { text: '未知角色', color: '#999999', bg: '#f5f5f5' })

// 头像展示姓名首字符
const avatarChar = computed(() => {
  const name = user.value.name || user.value.username || '管'
  return String(name).slice(0, 1)
})

onShow(() => {
  user.value = getUser() || {}
})

function handleLogout() {
  uni.showModal({
    title: '提示',
    content: '确定退出当前账号吗？',
    success: (res) => {
      if (res.confirm) {
        clear()
        uni.reLaunch({ url: '/pages/login/login' })
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.me-page {
  min-height: 100vh;
  background-color: $bg-page;
  padding: 32rpx;
  box-sizing: border-box;
}

.user-card {
  background-color: $primary;
  border-radius: $radius;
  padding: 40rpx 32rpx;
  display: flex;
  align-items: center;
  box-shadow: 0 8rpx 24rpx rgba(22, 119, 255, 0.2);
}

.avatar {
  width: 112rpx;
  height: 112rpx;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.25);
  border: 2rpx solid rgba(255, 255, 255, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-text {
  font-size: 52rpx;
  color: #ffffff;
  font-weight: bold;
}

.user-info {
  flex: 1;
  margin-left: 24rpx;
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 34rpx;
  font-weight: bold;
  color: #ffffff;
}

.user-account {
  margin-top: 8rpx;
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.85);
}

.role-tag {
  font-size: 22rpx;
  padding: 6rpx 16rpx;
  border-radius: 8rpx;
}

.info-card {
  margin-top: 32rpx;
  background-color: $bg-card;
  border-radius: $radius;
  padding: 8rpx 32rpx;
}

.info-row {
  height: 96rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1rpx solid $border-color;

  &:last-child {
    border-bottom: none;
  }
}

.info-label {
  font-size: 28rpx;
  color: $text-sub;
}

.info-value {
  font-size: 28rpx;
  color: $text-main;
}

.logout-btn {
  margin-top: 64rpx;
  height: 88rpx;
  line-height: 88rpx;
  background-color: #ffffff;
  color: $danger;
  font-size: 30rpx;
  border-radius: $radius;
  border: 1rpx solid $danger-bg;

  &::after {
    border: none;
  }
}

.version-text {
  display: block;
  text-align: center;
  margin-top: 40rpx;
  font-size: 22rpx;
  color: $text-grey;
}
</style>
