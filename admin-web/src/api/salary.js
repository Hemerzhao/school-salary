import request from '@/utils/request'

// ---- 计算 ----
export function calcMonth(month) {
  return request.post('/salary/calc', null, { params: { month } })
}
export function validate(month) {
  return request.get('/salary/validate', { params: { month } })
}

// ---- 工资单 ----
export function statementList(params) {
  return request.get('/salary/statement/page', { params })
}
export function statementDetail(id) {
  return request.get(`/salary/statement/${id}`)
}
export function statementConfirm(id) {
  return request.post(`/salary/statement/${id}/confirm`)
}
export function statementLock(id) {
  return request.post(`/salary/statement/${id}/lock`)
}
export function statementUnlock(id) {
  return request.post(`/salary/statement/${id}/unlock`)
}
export function statementMarkPaid(id) {
  return request.post(`/salary/statement/${id}/mark-paid`)
}

// ---- 调整项 ----
export function adjustmentCreate(data) {
  return request.post('/salary/adjustment', data)
}
export function adjustmentConfirm(id) {
  return request.post(`/salary/adjustment/${id}/confirm`)
}

// ---- 明细 & 快照 ----
export function detailList(statementId) {
  return request.get('/salary/detail/list', { params: { statementId } })
}
export function snapshot(id) {
  return request.get(`/salary/snapshot/${id}`)
}
