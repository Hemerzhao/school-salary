// uni.request 统一封装：自动携带 token、统一响应处理、错误提示、401 自动跳登录
import { getToken, clear as clearUser } from '../store/user'

// #ifdef H5
// H5 环境走 vite 代理（见 vite.config.js），避免开发期跨域
const BASE_URL = '/api'
// #endif
// #ifdef APP-PLUS || MP-WEIXIN
// App 与小程序直连后端，上线时请改成正式服务器地址
const BASE_URL = 'http://localhost:8080/api'
// #endif

function doRequest(options) {
  return new Promise((resolve, reject) => {
    const token = getToken()
    uni.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data || {},
      header: Object.assign(
        { 'Content-Type': 'application/json' },
        token ? { Authorization: 'Bearer ' + token } : {},
        options.header || {}
      ),
      success: (res) => {
        // HTTP 401：未登录或登录过期，清除本地登录态并跳转登录页
        if (res.statusCode === 401) {
          clearUser()
          uni.reLaunch({ url: '/pages/login/login' })
          reject(new Error('登录已过期，请重新登录'))
          return
        }
        const body = res.data
        // 统一响应结构 { code, msg, data }，code=0 为成功
        if (res.statusCode >= 200 && res.statusCode < 300 && body && body.code === 0) {
          resolve(body.data)
          return
        }
        const msg = (body && body.msg) || '请求失败（' + res.statusCode + '）'
        uni.showToast({ title: msg, icon: 'none' })
        reject(new Error(msg))
      },
      fail: (err) => {
        uni.showToast({ title: '网络异常，请稍后重试', icon: 'none' })
        reject(err)
      }
    })
  })
}

export function get(url, data) {
  return doRequest({ url, method: 'GET', data })
}

export function post(url, data) {
  return doRequest({ url, method: 'POST', data })
}

export default doRequest
