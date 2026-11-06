// 时间、金额与状态格式化工具

// '2026-11-06 09:00:00' -> '09:00'
export function formatTime(timeStr) {
  if (!timeStr) return ''
  const t = timeStr.split(' ')[1] || ''
  return t.slice(0, 5)
}

// '2026-11-06 09:00:00' -> '11-06'
export function formatDate(timeStr) {
  if (!timeStr) return ''
  const d = (timeStr.split(' ')[0] || '').split('-')
  if (d.length < 3) return timeStr
  return d[1] + '-' + d[2]
}

// 金额展示：保留两位小数（后端直接给元，不做分转元）
export function formatMoney(val) {
  const n = Number(val || 0)
  return n.toFixed(2)
}

/* 打卡审核状态：0 待审核 / 1 通过 / 2 驳回 */
export const auditStatusMap = {
  0: { text: '待审核', color: '#fa8c16' },
  1: { text: '已通过', color: '#52c41a' },
  2: { text: '已驳回', color: '#f5222d' }
}

export function auditStatusText(status) {
  const item = auditStatusMap[status]
  return item ? item.text : '未知'
}

export function auditStatusColor(status) {
  const item = auditStatusMap[status]
  return item ? item.color : '#999999'
}

/* 工资单状态：0 草稿 / 1 已确认 / 2 已锁定 / 3 已发放 */
export const salaryStatusMap = {
  0: { text: '草稿', color: '#999999' },
  1: { text: '已确认', color: '#1677ff' },
  2: { text: '已锁定', color: '#fa8c16' },
  3: { text: '已发放', color: '#52c41a' }
}

export function salaryStatusText(status) {
  const item = salaryStatusMap[status]
  return item ? item.text : '未知'
}

export function salaryStatusColor(status) {
  const item = salaryStatusMap[status]
  return item ? item.color : '#999999'
}

/* 排课类型：NORMAL 正常 / TRIAL 试听 / SUPPLEMENT 补课 */
export function scheduleTypeText(type) {
  if (type === 'TRIAL') return '试听'
  if (type === 'SUPPLEMENT') return '补课'
  return '正常'
}

// 试听/补课显示灰色 tag，正常显示主色 tag
export function scheduleTypeClass(type) {
  if (type === 'TRIAL' || type === 'SUPPLEMENT') return 'type-gray'
  return 'type-normal'
}
