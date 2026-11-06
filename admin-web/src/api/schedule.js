import request from '@/utils/request'

export function page(params) {
  return request.get('/schedule/page', { params })
}

export function list(params) {
  return request.get('/schedule/list', { params })
}

export function create(data) {
  return request.post('/schedule', data)
}

export function update(data) {
  return request.put('/schedule', data)
}

export function remove(id) {
  return request.delete(`/schedule/${id}`)
}
