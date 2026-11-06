// 用户登录态本地存储模块（基于 uni storage 同步 API）
const TOKEN_KEY = 'admin_app_token'
const USER_KEY = 'admin_app_user'

export function getToken() {
  return uni.getStorageSync(TOKEN_KEY) || ''
}

export function setToken(token) {
  uni.setStorageSync(TOKEN_KEY, token || '')
}

export function getUser() {
  try {
    const raw = uni.getStorageSync(USER_KEY)
    if (!raw) return null
    // 兼容存为 JSON 字符串与对象两种情况
    if (typeof raw === 'string') {
      return JSON.parse(raw)
    }
    return raw
  } catch (e) {
    return null
  }
}

export function setUser(user) {
  uni.setStorageSync(USER_KEY, JSON.stringify(user || {}))
}

export function clear() {
  uni.removeStorageSync(TOKEN_KEY)
  uni.removeStorageSync(USER_KEY)
}

/**
 * 角色判断：当前用户角色是否在给定角色列表中
 * 角色取值：SUPER_ADMIN 超管 / SALARY_ADMIN 计费管理员 / FINANCE 财务
 *          JIAOWU 教务 / CAMPUS_ADMIN 校区管理员 / TEACHER 教师
 * @param  {...string} roles 允许的角色列表
 * @returns {boolean}
 */
export function hasRole(...roles) {
  const user = getUser()
  if (!user || !user.role) return false
  return roles.indexOf(user.role) !== -1
}

// 通用角色组判断（便捷封装）

/** 是否超管 */
export function isSuperAdmin() {
  return hasRole('SUPER_ADMIN')
}

/** 是否可管理工资（超管 / 计费管理员） */
export function isSalaryManager() {
  return hasRole('SUPER_ADMIN', 'SALARY_ADMIN')
}

/** 是否可使用工资模块（超管 / 计费管理员 / 财务） */
export function canUseSalary() {
  return hasRole('SUPER_ADMIN', 'SALARY_ADMIN', 'FINANCE')
}

/** 是否可审核打卡（超管 / 计费管理员 / 教务 / 校区管理员） */
export function canAudit() {
  return hasRole('SUPER_ADMIN', 'SALARY_ADMIN', 'JIAOWU', 'CAMPUS_ADMIN')
}
