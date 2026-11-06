import request from '@/utils/request'

export function page(params) {
  return request.get('/teacher/page', { params })
}

export function list(params) {
  return request.get('/teacher/list', { params })
}

export function create(data) {
  return request.post('/teacher', data)
}

export function update(data) {
  return request.put('/teacher', data)
}

export function remove(id) {
  return request.delete(`/teacher/${id}`)
}
