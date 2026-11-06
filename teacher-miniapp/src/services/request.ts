import Taro from '@tarojs/taro'
import { getToken, clearAuth } from '../utils/storage'

const BASE_URL = process.env.BASE_URL as string

export interface Result<T = any> {
  code: number
  data: T
  msg?: string
}

export interface RequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  params?: Record<string, any>
  data?: any
}

function buildQuery(params?: Record<string, any>): string {
  if (!params) return ''
  const qs = Object.keys(params)
    .filter(k => params[k] !== undefined && params[k] !== null && params[k] !== '')
    .map(k => `${encodeURIComponent(k)}=${encodeURIComponent(String(params[k]))}`)
    .join('&')
  return qs ? `?${qs}` : ''
}

export async function request<T = any>(path: string, options: RequestOptions = {}): Promise<T> {
  const token = getToken()
  const { method = 'GET', params, data } = options

  const query = method === 'GET' ? buildQuery(params) : ''
  const url = `${BASE_URL}${path}${query}`

  try {
    const res = await Taro.request({
      url,
      method,
      data: method === 'GET' ? undefined : (data ?? params),
      header: {
        'Content-Type': 'application/json',
        Authorization: token ? `Bearer ${token}` : ''
      }
    })

    const body = res.data as Result<T>

    if (body.code === 0) {
      return body.data
    }

    if (body.code === 401) {
      Taro.showToast({ title: '请重新登录', icon: 'none' })
      clearAuth()
      Taro.reLaunch({ url: '/pages/me/index' })
      throw new Error(body.msg || '未授权')
    }

    Taro.showToast({ title: body.msg || '请求失败', icon: 'none' })
    throw new Error(body.msg || '请求失败')
  } catch (err: any) {
    if (err && (err as any).code === 401) {
      clearAuth()
      Taro.reLaunch({ url: '/pages/me/index' })
    }
    throw err
  }
}
