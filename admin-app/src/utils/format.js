// 时间、金额、状态与角色格式化工具

// 兼容 "2026-11-06 09:00:00" 与 ISO "2026-11-06T09:00:00" 两种格式，统一为空格分隔
function normalize(timeStr) {
  if (!timeStr) return ''
  return String(timeStr).replace('T', ' ')
}

// '2026-11-06 09:00:00' -> '09:00'
export function formatTime(timeStr) {
  const t = normalize(timeStr).split(' ')[1] || ''
  return t.slice(0, 5)
}

// '2026-11-06 09:00:00' -> '11-06'
export function formatDate(timeStr) {
  const d = (normalize(timeStr).split(' ')[0] || '').split('-')
  if (d.length < 3) return timeStr || ''
  return d[1] + '-' + d[2]
}

// '2026-11-06 09:00:00' -> '11-06 09:00'
export function formatDateTime(timeStr) {
  const s = normalize(timeStr)
  if (!s) return ''
  const parts = s.split(' ')
  const date = (parts[0] || '').slice(5) // MM-DD
  const time = (parts[1] || '').slice(0, 5) // HH:mm
  return (date + ' ' + time).trim()
}

// 金额展示：保留两位小数（后端直接给元，不做分转元）
export function formatMoney(val) {
  const n = Number(val || 0)
  return n.toFixed(2)
}

// 时长（分钟）-> '90分钟' / '1.5小时'
export function formatDuration(minutes) {
  const n = Number(minutes || 0)
  if (n > 0 && n % 60 === 0) return n / 60 + '小时'
  return n + '分钟'
}

/* 打卡审核状态：0 待审核 / 1 通过 / 2 驳回 */
export const auditStatusMap = {
  0: { text: '待审核', color: '#fa8c16', bg: '#fff7e6' },
  1: { text: '已通过', color: '#52c41a', bg: '#f6ffed' },
  2: { text: '已驳回', color: '#f5222d', bg: '#fff1f0' }
}

export function auditStatusText(status) {
  const item = auditStatusMap[status]
  return item ? item.text : '未知'
}

export function auditStatusInfo(status) {
  return auditStatusMap[status] || { text: '未知', color: '#999999', bg: '#f5f5f5' }
}

/* 工资单状态：0 草稿 / 1 已确认 / 2 已锁定 / 3 已发放 */
export const salaryStatusMap = {
  0: { text: '草稿', color: '#999999', bg: '#f5f5f5' },
  1: { text: '已确认', color: '#1677ff', bg: '#e6f0ff' },
  2: { text: '已锁定', color: '#fa8c16', bg: '#fff7e6' },
  3: { text: '已发放', color: '#52c41a', bg: '#f6ffed' }
}

export function salaryStatusText(status) {
  const item = salaryStatusMap[status]
  return item ? item.text : '未知'
}

export function salaryStatusInfo(status) {
  return salaryStatusMap[status] || { text: '未知', color: '#999999', bg: '#f5f5f5' }
}

/* 调整项状态：0 草稿 / 1 已确认 */
export function adjustStatusText(status) {
  return status === 1 ? '已确认' : '草稿'
}

/* 排课类型：NORMAL 正常 / TRIAL 试听 / SUPPLEMENT 补课 */
export function scheduleTypeText(type) {
  if (type === 'TRIAL') return '试听'
  if (type === 'SUPPLEMENT') return '补课'
  return '正常'
}

/* 排课状态：1 待上 / 2 进行中 / 3 已完成 / 4 已取消 */
export const scheduleStatusMap = {
  1: { text: '待上', color: '#1677ff', bg: '#e6f0ff' },
  2: { text: '进行中', color: '#fa8c16', bg: '#fff7e6' },
  3: { text: '已完成', color: '#52c41a', bg: '#f6ffed' },
  4: { text: '已取消', color: '#999999', bg: '#f5f5f5' }
}

export function scheduleStatusInfo(status) {
  return scheduleStatusMap[status] || { text: '未知', color: '#999999', bg: '#f5f5f5' }
}

/* 用户角色：超管 / 计费管理员 / 财务 / 教务 / 校区管理员 / 教师 */
export const roleMap = {
  SUPER_ADMIN: { text: '超级管理员', color: '#f5222d', bg: '#fff1f0' },
  SALARY_ADMIN: { text: '计费管理员', color: '#1677ff', bg: '#e6f0ff' },
  FINANCE: { text: '财务', color: '#52c41a', bg: '#f6ffed' },
  JIAOWU: { text: '教务', color: '#fa8c16', bg: '#fff7e6' },
  CAMPUS_ADMIN: { text: '校区管理员', color: '#722ed1', bg: '#f9f0ff' },
  TEACHER: { text: '教师', color: '#999999', bg: '#f5f5f5' }
}

export function roleText(role) {
  const item = roleMap[role]
  return item ? item.text : role || '未知'
}
