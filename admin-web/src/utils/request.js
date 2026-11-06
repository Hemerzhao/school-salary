import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const service = axios.create({
  baseURL: '/api',
  timeout: 15000
})

// 请求拦截
service.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 响应拦截
service.interceptors.response.use(
  (response) => {
    const res = response.data
    // 后端 Result 结构：{ code: 0, msg: "ok", data: any }
    if (res && typeof res === 'object' && 'code' in res) {
      if (res.code === 0) {
        return res.data
      } else if (res.code === 401) {
        ElMessage.error(res.msg || '登录已过期，请重新登录')
        const userStore = useUserStore()
        userStore.logout()
        window.location.href = '/admin/login'
        return Promise.reject(new Error(res.msg || 'Unauthorized'))
      } else {
        ElMessage.error(res.msg || '请求失败')
        return Promise.reject(new Error(res.msg || 'Request failed'))
      }
    }
    // 非 Result 结构直接返回（兼容纯下载等）
    return res
  },
  (error) => {
    if (error.response?.status === 401) {
      ElMessage.error('登录已过期，请重新登录')
      localStorage.removeItem('token')
      window.location.href = '/admin/login'
    } else {
      ElMessage.error(error.message || '网络异常')
    }
    return Promise.reject(error)
  }
)

export default service
