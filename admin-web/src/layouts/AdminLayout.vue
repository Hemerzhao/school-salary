<template>
  <el-container class="admin-layout">
    <el-aside width="220px" class="aside">
      <div class="logo">
        <el-icon size="22" color="#fff"><Money /></el-icon>
        <span>教师工资系统</span>
      </div>
      <el-menu
        :default-active="route.path"
        router
        background-color="#001529"
        text-color="#c9d1d9"
        active-text-color="#ffffff"
        unique-opened
      >
        <template v-for="item in visibleMenus" :key="item.path">
          <el-menu-item :index="item.fullPath">
            <el-icon><component :is="item.meta.icon" /></el-icon>
            <span>{{ item.meta.title }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header class="header">
        <div class="header-left">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/admin/dashboard' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item>{{ route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-dropdown trigger="click" @command="onCommand">
            <span class="user-info">
              <el-avatar :size="30">{{ userStore.name?.[0] || 'U' }}</el-avatar>
              <span class="username">{{ userStore.name || userStore.user?.username || '未登录' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main class="main">
        <router-view v-slot="{ Component }">
          <keep-alive>
            <component :is="Component" />
          </keep-alive>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 基于角色过滤菜单（从路由表 children 里取）
const roleMenuMap = {
  SALARY_ADMIN: ['rule/template', 'rule/binding', 'rule/preview', 'salary/calc', 'salary/statement', 'audit'],
  CAMPUS_ADMIN: ['campus', 'class', 'schedule', 'attendance'],
  JIAOWU: ['schedule', 'attendance', 'class'],
  FINANCE: ['salary/calc', 'salary/statement', 'salary/detail', 'audit']
}

const visibleMenus = computed(() => {
  const role = userStore.role
  // 拿到 AdminLayout 的 children 路由
  const children = router.options.routes.find(r => r.path === '/admin')?.children || []
  if (!role || role === 'SUPER_ADMIN') {
    return children.filter(r => r.path !== '')
  }
  const allowList = roleMenuMap[role] || []
  return children.filter(r => allowList.includes(r.path))
})

const onCommand = (cmd) => {
  if (cmd === 'logout') {
    userStore.logout()
    router.push('/admin/login')
  }
}
</script>

<style scoped>
.admin-layout {
  height: 100vh;
}
.aside {
  background-color: #001529;
  color: #fff;
  display: flex;
  flex-direction: column;
}
.aside .logo {
  height: 56px;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 16px;
  font-weight: 600;
  font-size: 16px;
  color: #fff;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}
.aside .el-menu {
  flex: 1;
  border-right: none;
}
.header {
  background-color: #fff;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 16px;
  height: 56px;
}
.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}
.main {
  padding: 0;
  overflow-y: auto;
  background-color: #f5f7fa;
}
</style>
