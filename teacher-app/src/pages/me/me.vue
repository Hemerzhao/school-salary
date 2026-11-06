<template>
  <view class="page">
    <!-- 用户信息卡片 -->
    <view class="user-card">
      <view class="avatar">
        <text class="avatar-text">{{ avatarText }}</text>
      </view>
      <view class="user-info">
        <text class="user-name">{{ user.name || user.username || '-' }}</text>
        <text class="user-role">{{ roleText }}</text>
      </view>
    </view>

    <!-- 详细信息列表 -->
    <view class="info-card">
      <view class="info-row">
        <text class="info-label">工号</text>
        <text class="info-value">{{ user.username || '-' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">姓名</text>
        <text class="info-value">{{ user.name || '-' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">角色</text>
        <text class="info-value">{{ roleText }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">绑定校区</text>
        <text class="info-value">{{ campusText }}</text>
      </view>
    </view>

    <button class="logout-btn" @click="handleLogout">退出登录</button>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getUser, clear } from '../../store/user'

const user = ref({})

const roleMap = {
  TEACHER: '教师',
  ADMIN: '管理员',
  CAMPUS_ADMIN: '校区管理员'
}

const roleText = computed(() => roleMap[user.value.role] || user.value.role || '教师')

const avatarText = computed(() => (user.value.name || user.value.username || '师').slice(0, 1))

const campusText = computed(() =>
  user.value.campusId != null ? '校区 ' + user.value.campusId : '未绑定'
)

onShow(() => {
  const u = getUser()
  if (!u) {
    uni.reLaunch({ url: '/pages/login/login' })
    return
  }
  user.value = u
})

function handleLogout() {
  uni.showModal({
    title: '提示',
    content: '确定要退出登录吗？',
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
.page {
  padding: 24rpx;
}

.user-card {
  background: linear-gradient(135deg, $primary 0%, #4d94ff 100%);
  border-radius: $radius;
  padding: 40rpx 32rpx;
  margin-bottom: 24rpx;
  display: flex;
  align-items: center;
}

.avatar {
  width: 110rpx;
  height: 110rpx;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.25);
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-text {
  font-size: 44rpx;
  color: #ffffff;
  font-weight: bold;
}

.user-info {
  margin-left: 28rpx;
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 38rpx;
  font-weight: bold;
  color: #ffffff;
}

.user-role {
  margin-top: 12rpx;
  align-self: flex-start;
  font-size: 22rpx;
  color: #ffffff;
  background-color: rgba(255, 255, 255, 0.2);
  padding: 4rpx 20rpx;
  border-radius: 24rpx;
}

.info-card {
  background-color: $bg-card;
  border-radius: $radius;
  padding: 8rpx 28rpx;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 96rpx;
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
  font-weight: 500;
}

.logout-btn {
  margin-top: 48rpx;
  height: 88rpx;
  line-height: 88rpx;
  background-color: $bg-card;
  color: $danger;
  font-size: 30rpx;
  border-radius: $radius;

  &::after {
    border: none;
  }
}
</style>
