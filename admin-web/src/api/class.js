import request from '@/utils/request'

export function list(params) {
  return request.get('/class/list', { params })
}

export function create(data) {
  return request.post('/class', data)
}

export function update(data) {
  return request.put('/class', data)
}

export function remove(id) {
  return request.delete(`/class/${id}`)
}
