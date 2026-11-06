// 工资单相关接口
import { get } from '../utils/request'

// 工资单分页列表，返回 { records: [], total }
export function statementList(teacherId, page = 1, size = 20) {
  return get('/salary/statement/list', { teacherId, page, size })
}

// 工资单详情，返回 { statement, details: [], adjustments: [] }
export function statementDetail(id) {
  return get('/salary/statement/' + id)
}
