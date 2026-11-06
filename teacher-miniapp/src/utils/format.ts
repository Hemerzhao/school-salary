export function pad(n: number): string {
  return n < 10 ? `0${n}` : String(n)
}

export function formatTime(d: Date): string {
  return `${pad(d.getHours())}:${pad(d.getMinutes())}`
}

export function formatDate(d: Date): string {
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

export function formatDateTime(d: Date): string {
  return `${formatDate(d)} ${formatTime(d)}`
}

export function formatMoney(n: number): string {
  return `¥${Number(n || 0).toFixed(2)}`
}
