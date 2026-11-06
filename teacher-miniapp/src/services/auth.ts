import { request } from './request'
import { setToken, setUser } from '../utils/storage'

export interface UserInfo {
  id: string
  username: string
  name: string
  role: string
  employeeNo?: string
  campus?: string
  level?: string
}

export interface LoginResult {
  token: string
  user: UserInfo
}

export async function login(username: string, password: string): Promise<LoginResult> {
  const data = await request<LoginResult>('/auth/login', {
    method: 'POST',
    data: { username, password }
  })
  setToken(data.token)
  setUser(data.user)
  return data
}
