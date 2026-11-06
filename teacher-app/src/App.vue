<script setup>
import { onLaunch } from '@dcloudio/uni-app'
import { getToken } from './store/user'

onLaunch(() => {
  // 启动时检查本地登录态，未登录则跳转登录页
  if (!getToken()) {
    uni.reLaunch({ url: '/pages/login/login' })
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
