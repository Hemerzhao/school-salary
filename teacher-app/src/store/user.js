// 用户登录态本地存储模块（基于 uni storage 同步 API）
const TOKEN_KEY = 'teacher_app_token'
const USER_KEY = 'teacher_app_user'

export function getToken() {
  return uni.getStorageSync(TOKEN_KEY) || ''
}

export function setToken(token) {
  uni.setStorageSync(TOKEN_KEY, token || '')
}

export function getUser() {
  try {
    const raw = uni.getStorageSync(USER_KEY)
    if (!raw) return null
    // 兼容存为 JSON 字符串与对象两种情况
    if (typeof raw === 'string') {
      return JSON.parse(raw)
    }
    return raw
  } catch (e) {
    return null
  }
}

export function setUser(user) {
  uni.setStorageSync(USER_KEY, JSON.stringify(user || {}))
}

export function clear() {
  uni.removeStorageSync(TOKEN_KEY)
  uni.removeStorageSync(USER_KEY)
}
