<template>
  <view class="dashboard-page">
    <!-- 顶部问候区 -->
    <view class="header">
      <text class="hello">你好，{{ user.name || user.username || '管理员' }}</text>
      <text class="role-tag" :style="{ color: roleInfo.color, backgroundColor: roleInfo.bg }">
        {{ roleInfo.text }}
      </text>
    </view>
    <text class="sub-hello">今天想处理点什么？</text>

    <!-- 功能入口宫格（按角色过滤） -->
    <view class="grid-card">
      <view class="grid">
        <view
          v-for="item in menus"
          :key="item.url"
          class="grid-item"
          hover-class="grid-item-hover"
          @click="go(item.url)"
        >
          <view class="grid-icon" :style="{ backgroundColor: item.bg }">
            <text class="grid-icon-text">{{ item.icon }}</text>
          </view>
          <text class="grid-label">{{ item.label }}</text>
        </view>
      </view>
      <view v-if="menus.length === 0" class="empty-block">
        <text class="empty-text">当前角色没有可用功能，请联系管理员</text>
      </view>
    </view>

    <!-- 角色说明 -->
    <view class="role-tip-card">
      <text class="role-tip-title">权限说明</text>
      <text class="role-tip-item">· 超管 / 计费管理员：全部功能</text>
      <text class="role-tip-item">· 财务：工资计算、工资单、调整项、规则校验</text>
      <text class="role-tip-item">· 教务 / 校区管理员：打卡审核、排课查看</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getUser, canUseSalary, canAudit, isSalaryManager, isSuperAdmin } from '../../store/user'
import { roleText, roleMap } from '../../utils/format'

const user = ref(getUser() || {})

const roleInfo = computed(() => roleMap[user.value.role] || { text: '未知角色', color: '#999999', bg: '#f5f5f5' })

// 全量功能清单，按角色过滤展示
const allMenus = [
  { label: '打卡审核', icon: '审', url: '/pages/attendance/attendance', bg: '#e6f0ff', show: () => canAudit() },
  { label: '排课查看', icon: '课', url: '/pages/schedule/schedule', bg: '#e6fffb', show: () => canAudit() },
  { label: '工资计算', icon: '算', url: '/pages/salary/calc', bg: '#fff7e6', show: () => canUseSalary() },
  { label: '工资单', icon: '资', url: '/pages/salary/statement', bg: '#f6ffed', show: () => canUseSalary() },
  { label: '调整项', icon: '调', url: '/pages/salary/adjustment', bg: '#f9f0ff', show: () => canUseSalary() },
  { label: '规则校验', icon: '规', url: '/pages/rule/validate', bg: '#fff1f0', show: () => canUseSalary() },
  { label: '审计日志', icon: '志', url: '/pages/audit/audit', bg: '#f5f5f5', show: () => isSalaryManager() || isSuperAdmin() }
]

// 按角色过滤后的菜单（computed 保证登录态变化时自动刷新）
const menus = computed(() => allMenus.filter((m) => m.show()))

// 每次进入工作台刷新用户信息（token 变化后 reLaunch 会重新进入）
onShow(() => {
  user.value = getUser() || {}
})

function go(url) {
  // tabBar 页面必须用 switchTab，其余用 navigateTo
  const tabPages = ['/pages/dashboard/dashboard', '/pages/attendance/attendance', '/pages/salary/statement', '/pages/me/me']
  if (tabPages.indexOf(url) !== -1) {
    uni.switchTab({ url })
  } else {
    uni.navigateTo({ url })
  }
}
</script>

<style lang="scss" scoped>
.dashboard-page {
  min-height: 100vh;
  background-color: $bg-page;
  padding: 32rpx;
  box-sizing: border-box;
}

.header {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.hello {
  font-size: 40rpx;
  font-weight: bold;
  color: $text-main;
}

.role-tag {
  font-size: 22rpx;
  padding: 4rpx 16rpx;
  border-radius: 8rpx;
}

.sub-hello {
  display: block;
  margin-top: 12rpx;
  margin-bottom: 32rpx;
  font-size: 26rpx;
  color: $text-grey;
}

.grid-card {
  background-color: $bg-card;
  border-radius: $radius;
  padding: 24rpx 8rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.grid {
  display: flex;
  flex-wrap: wrap;
}

.grid-item {
  width: 25%;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24rpx 0;
}

.grid-item-hover {
  opacity: 0.7;
}

.grid-icon {
  width: 88rpx;
  height: 88rpx;
  border-radius: 24rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.grid-icon-text {
  font-size: 36rpx;
  font-weight: bold;
  color: $primary;
}

.grid-label {
  margin-top: 16rpx;
  font-size: 24rpx;
  color: $text-sub;
}

.empty-block {
  padding: 48rpx 0;
  display: flex;
  justify-content: center;
}

.empty-text {
  font-size: 26rpx;
  color: $text-grey;
}

.role-tip-card {
  margin-top: 32rpx;
  background-color: $bg-card;
  border-radius: $radius;
  padding: 28rpx 32rpx;
  display: flex;
  flex-direction: column;
}

.role-tip-title {
  font-size: 28rpx;
  font-weight: 500;
  color: $text-main;
  margin-bottom: 16rpx;
}

.role-tip-item {
  font-size: 24rpx;
  color: $text-sub;
  line-height: 44rpx;
}
</style>
