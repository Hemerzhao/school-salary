import request from '@/utils/request'

export function login(username, password) {
  return request.post('/auth/login', { username, password })
}

export function profile() {
  return request.get('/auth/profile')
}
