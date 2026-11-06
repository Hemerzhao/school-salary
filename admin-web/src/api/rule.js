import request from '@/utils/request'

// ---- 模板 ----
export function templateList(params) {
  return request.get('/rule/template/list', { params })
}
export function templateCreate(data) {
  return request.post('/rule/template', data)
}
export function templateUpdate(data) {
  return request.put('/rule/template', data)
}
export function templateDelete(id) {
  return request.delete(`/rule/template/${id}`)
}

// ---- 版本 ----
export function versionCreate(data) {
  return request.post('/rule/version', data)
}
export function versionUpdate(data) {
  return request.put('/rule/version', data)
}
export function versionPublish(id) {
  return request.post(`/rule/version/${id}/publish`)
}
export function versionDisable(id) {
  return request.post(`/rule/version/${id}/disable`)
}

// ---- 绑定 ----
export function bindingList(params) {
  return request.get('/rule/binding/list', { params })
}
export function bindingCreate(data) {
  return request.post('/rule/binding', data)
}
export function bindingUpdate(data) {
  return request.put('/rule/binding', data)
}
export function bindingDelete(id) {
  return request.delete(`/rule/binding/${id}`)
}

// ---- 工具 ----
export function preview(teacherId, date) {
  return request.get('/rule/preview', { params: { teacherId, date } })
}
export function validate(month) {
  return request.get('/rule/validate', { params: { month } })
}
