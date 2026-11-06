<template>
  <view class="login-page">
    <!-- 顶部 Logo 区域（纯文字） -->
    <view class="logo-area">
      <view class="logo-badge">
        <text class="logo-badge-text">管</text>
      </view>
      <text class="logo-title">工资管理端</text>
      <text class="logo-subtitle">打卡审核 · 排课查看 · 工资发放</text>
    </view>

    <!-- 登录表单卡片 -->
    <view class="form-card">
      <view class="form-item">
        <text class="form-label">用户名</text>
        <input
          class="form-input"
          v-model="username"
          placeholder="请输入管理员用户名"
          placeholder-class="input-placeholder"
        />
      </view>
      <view class="form-item">
        <text class="form-label">密码</text>
        <input
          class="form-input"
          v-model="password"
          password
          placeholder="请输入密码"
          placeholder-class="input-placeholder"
        />
      </view>
      <button class="login-btn" :loading="loading" :disabled="loading" @click="handleLogin">
        登 录
      </button>
    </view>

    <text class="login-tip">仅限管理人员使用，教师请使用教师端</text>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { get, post } from '../../utils/request'
import { setToken, setUser } from '../../store/user'

const username = ref('')
const password = ref('')
const loading = ref(false)

async function handleLogin() {
  if (!username.value.trim()) {
    uni.showToast({ title: '请输入用户名', icon: 'none' })
    return
  }
  if (!password.value) {
    uni.showToast({ title: '请输入密码', icon: 'none' })
    return
  }
  loading.value = true
  try {
    // POST /auth/login → data: { token, user: { id, username, name, role, campusId } }
    const data = await post('/auth/login', {
      username: username.value.trim(),
      password: password.value
    })
    const user = data.user || {}

    // 按角色控制入口：管理端不开放教师角色
    if (user.role === 'TEACHER') {
      uni.showToast({ title: '教师请使用教师端登录', icon: 'none' })
      return
    }

    setToken(data.token)
    setUser(user)
    uni.showToast({ title: '登录成功', icon: 'success' })
    setTimeout(() => {
      uni.reLaunch({ url: '/pages/dashboard/dashboard' })
    }, 600)
  } catch (e) {
    // 登录失败提示已在 request 封装中统一处理
  } finally {
    loading.value = false
  }
}
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(180deg, $primary 0%, #4d94ff 32%, $bg-page 72%);
  padding: 0 48rpx;
  box-sizing: border-box;
}

.logo-area {
  padding-top: 180rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.logo-badge {
  width: 128rpx;
  height: 128rpx;
  border-radius: 32rpx;
  background-color: rgba(255, 255, 255, 0.2);
  border: 2rpx solid rgba(255, 255, 255, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-badge-text {
  font-size: 64rpx;
  color: #ffffff;
  font-weight: bold;
}

.logo-title {
  margin-top: 32rpx;
  font-size: 44rpx;
  font-weight: bold;
  color: #ffffff;
  letter-spacing: 4rpx;
}

.logo-subtitle {
  margin-top: 16rpx;
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
}

.form-card {
  margin-top: 72rpx;
  background-color: $bg-card;
  border-radius: $radius;
  padding: 48rpx 40rpx;
  box-shadow: 0 8rpx 32rpx rgba(22, 119, 255, 0.1);
}

.form-item {
  margin-bottom: 36rpx;
}

.form-label {
  font-size: 28rpx;
  color: $text-main;
  font-weight: 500;
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

.login-btn {
  margin-top: 16rpx;
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

.login-tip {
  display: block;
  text-align: center;
  margin-top: 48rpx;
  font-size: 24rpx;
  color: $text-grey;
}
</style>
