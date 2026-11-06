// 登录相关接口
import request from '../utils/request'

// 用户名密码登录，成功返回 { token, user }
export function login(username, password) {
  return request({ url: '/auth/login', method: 'POST', data: { username, password } })
}
