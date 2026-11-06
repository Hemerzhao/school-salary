import request from '@/utils/request'

export function list(params) {
  return request.get('/attendance/page', { params })
}

export function start(scheduleId) {
  return request.post('/attendance/start', { scheduleId })
}

export function end(attendanceId) {
  return request.post('/attendance/end', { attendanceId })
}

export function audit({ id, action, remark }) {
  return request.post('/attendance/audit', { id, action, remark })
}

export function makeup(attendanceId, data) {
  return request.post(`/attendance/${attendanceId}/makeup`, data)
}

export function my(params) {
  return request.get('/attendance/my', { params })
}
