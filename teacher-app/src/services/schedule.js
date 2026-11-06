// 排课相关接口
import { get } from '../utils/request'

// 按教师查询排课列表（startFrom / startTo 为 "yyyy-MM-dd HH:mm:ss"，与后端 @RequestParam 对齐）
export function listByTeacher(teacherId, from, to) {
  return get('/schedule/list', { teacherId, startFrom: from, startTo: to })
}
