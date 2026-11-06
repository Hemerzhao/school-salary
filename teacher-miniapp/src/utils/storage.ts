import Taro from '@tarojs/taro'
import type { UserInfo } from '../services/auth'

const TOKEN_KEY = 'token'
const USER_KEY = 'user'

export function getToken(): string {
  return Taro.getStorageSync(TOKEN_KEY) || ''
}

export function setToken(token: string): void {
  Taro.setStorageSync(TOKEN_KEY, token)
}

export function getUser(): UserInfo | null {
  try {
    const raw = Taro.getStorageSync(USER_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export function setUser(user: UserInfo): void {
  Taro.setStorageSync(USER_KEY, JSON.stringify(user))
}

export function clearAuth(): void {
  Taro.removeStorageSync(TOKEN_KEY)
  Taro.removeStorageSync(USER_KEY)
}
