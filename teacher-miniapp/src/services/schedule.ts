import { request } from './request'

export interface Schedule {
  id: string
  courseName: string
  className: string
  startTime: string
  endTime: string
  date: string
  status: 'not_started' | 'can_start' | 'in_progress' | 'finished'
  location?: string
}

export async function list(params: { teacherId?: string; from?: string; to?: string }): Promise<Schedule[]> {
  return request<Schedule[]>('/schedule/list', { method: 'GET', params })
}

export async function today(): Promise<Schedule[]> {
  return request<Schedule[]>('/schedule/today', { method: 'GET' })
}
