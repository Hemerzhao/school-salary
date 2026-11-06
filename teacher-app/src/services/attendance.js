// 考勤打卡相关接口
import { get, post } from '../utils/request'

// 开始打卡
export function start(scheduleId) {
  return post('/attendance/start/' + scheduleId)
}

// 结束打卡：payload { studentCount, leaveCount, durationMinutes, exceptionNote }
export function end(scheduleId, payload) {
  return post('/attendance/end/' + scheduleId, payload)
}

// 当前教师的打卡记录列表
export function my() {
  return get('/attendance/my')
}
