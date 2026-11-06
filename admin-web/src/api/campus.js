import request from '@/utils/request'

export function list(params) {
  return request.get('/campus/list', { params })
}

export function create(data) {
  return request.post('/campus', data)
}

export function update(data) {
  return request.put('/campus', data)
}

export function remove(id) {
  return request.delete(`/campus/${id}`)
}
