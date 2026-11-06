<template>
  <div class="login-page">
    <div class="login-left">
      <div class="brand">
        <el-icon size="48" color="#409eff"><Money /></el-icon>
        <h1>教师工资系统</h1>
        <p>Teacher Salary Management Platform</p>
      </div>
    </div>
    <div class="login-right">
      <div class="login-form">
        <h2>管理员登录</h2>
        <el-form ref="formRef" :model="form" :rules="rules" label-position="top" size="large" @submit.prevent="doLogin">
          <el-form-item label="用户名" prop="username">
            <el-input v-model="form.username" placeholder="请输入用户名" :prefix-icon="User" />
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" :prefix-icon="Lock" />
          </el-form-item>
          <el-button type="primary" class="login-btn" :loading="loading" @click="doLogin">登 录</el-button>
        </el-form>
        <p class="hint">默认账号：admin / 123456</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const form = ref({ username: '', password: '' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}
const formRef = ref(null)
const loading = ref(false)

const doLogin = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await userStore.login(form.value.username, form.value.password)
    ElMessage.success('登录成功')
    router.push('/admin/dashboard')
  } catch (_) {
    // ElMessage.error 已在 request 拦截中处理
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  display: flex;
  min-height: 100vh;
}
.login-left {
  flex: 1;
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
}
.brand {
  text-align: center;
}
.brand h1 {
  margin: 12px 0 4px;
  font-size: 28px;
}
.brand p {
  opacity: 0.8;
  font-size: 14px;
  margin: 0;
  letter-spacing: 2px;
}
.login-right {
  width: 440px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}
.login-form {
  width: 320px;
}
.login-form h2 {
  margin: 0 0 24px;
  font-size: 22px;
  color: #303133;
}
.login-btn {
  width: 100%;
}
.hint {
  text-align: center;
  color: #909399;
  font-size: 12px;
  margin-top: 16px;
}
</style>
