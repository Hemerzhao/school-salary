import request from '@/utils/request'

export function logList(params) {
  return request.get('/audit/log/page', { params })
}
