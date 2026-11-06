import request from '@/utils/request'

export function list(params) {
  return request.get('/course/list', { params })
}

export function create(data) {
  return request.post('/course', data)
}

export function update(data) {
  return request.put('/course', data)
}

export function remove(id) {
  return request.delete(`/course/${id}`)
}
