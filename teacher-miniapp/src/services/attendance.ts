import { request } from './request'

export interface Attendance {
  id: string
  scheduleId: string
  startTime?: string
  endTime?: string
  studentCount?: number
  leaveCount?: number
  durationMinutes?: number
  exceptionNote?: string
  status: string
}

export async function start(scheduleId: string): Promise<Attendance> {
  return request<Attendance>('/attendance/start', {
    method: 'POST',
    data: { scheduleId }
  })
}

export async function end(
  scheduleId: string,
  payload: { studentCount: number; leaveCount: number; durationMinutes?: number; exceptionNote?: string }
): Promise<Attendance> {
  return request<Attendance>('/attendance/end', {
    method: 'POST',
    data: { scheduleId, ...payload }
  })
}

export async function my(): Promise<Attendance[]> {
  return request<Attendance[]>('/attendance/my', { method: 'GET' })
}
