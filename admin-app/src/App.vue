<script setup>
import { onLaunch } from '@dcloudio/uni-app'
import { getToken, getUser, clear } from './store/user'

onLaunch(() => {
  // 启动时检查本地登录态，未登录则跳转登录页
  const token = getToken()
  const user = getUser()
  if (!token) {
    uni.reLaunch({ url: '/pages/login/login' })
    return
  }
  // 按角色控制入口：管理端不开放教师角色，发现后清除登录态并跳回登录页
  if (user && user.role === 'TEACHER') {
    uni.showToast({ title: '教师请使用教师端登录', icon: 'none' })
    clear()
    setTimeout(() => {
      uni.reLaunch({ url: '/pages/login/login' })
    }, 600)
  }
})
</script>

<style>
/* 全局基础样式 */
page {
  background-color: #f5f5f7;
  color: #333333;
  font-size: 28rpx;
}

/* 输入框占位符颜色（全局，供 placeholder-class 使用） */
.input-placeholder {
  color: #999999;
}
</style>
