import { request } from './request'

export interface SalaryStatement {
  id: string
  month: string
  baseSalary: number
  classFee: number
  bonus: number
  adjustment: number
  total: number
  status: number // 1 预计 2 已核算 3 已发放
}

export interface SalaryDetailItem {
  attendanceId: string
  date: string
  courseName: string
  classHours: number
  studentCount: number
  amount: number
  formula?: string
  params?: Record<string, any>
  trace?: string
}

export interface SalaryDetail extends SalaryStatement {
  items: SalaryDetailItem[]
}

export async function myStatements(): Promise<SalaryStatement[]> {
  return request<SalaryStatement[]>('/salary/statements', { method: 'GET' })
}

export async function detail(statementId: string): Promise<SalaryDetail> {
  return request<SalaryDetail>(`/salary/detail/${statementId}`, { method: 'GET' })
}
