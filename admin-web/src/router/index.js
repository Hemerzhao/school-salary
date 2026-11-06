import { createRouter, createWebHistory } from 'vue-router'
import AdminLayout from '@/layouts/AdminLayout.vue'

const routes = [
  {
    path: '/admin/login',
    name: 'Login',
    component: () => import('@/views/login/Login.vue'),
    meta: { title: '登录', public: true }
  },
  {
    path: '/admin',
    component: AdminLayout,
    redirect: '/admin/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('@/views/dashboard/Dashboard.vue'), meta: { title: '首页', icon: 'Odometer' } },
      { path: 'campus', name: 'CampusList', component: () => import('@/views/campus/CampusList.vue'), meta: { title: '校区管理', icon: 'OfficeBuilding', roles: ['CAMPUS_ADMIN', 'SUPER_ADMIN'] } },
      { path: 'teacher', name: 'TeacherList', component: () => import('@/views/teacher/TeacherList.vue'), meta: { title: '教师管理', icon: 'User', roles: ['SUPER_ADMIN'] } },
      { path: 'class', name: 'ClassList', component: () => import('@/views/class/ClassList.vue'), meta: { title: '班级管理', icon: 'School', roles: ['CAMPUS_ADMIN', 'JIAOWU', 'SUPER_ADMIN'] } },
      { path: 'course', name: 'CourseList', component: () => import('@/views/course/CourseList.vue'), meta: { title: '课程管理', icon: 'Reading', roles: ['SUPER_ADMIN'] } },
      { path: 'schedule', name: 'ScheduleList', component: () => import('@/views/schedule/ScheduleList.vue'), meta: { title: '排课管理', icon: 'Calendar', roles: ['CAMPUS_ADMIN', 'JIAOWU', 'SUPER_ADMIN'] } },
      { path: 'attendance', name: 'AttendanceList', component: () => import('@/views/attendance/AttendanceList.vue'), meta: { title: '打卡审核', icon: 'Stamp', roles: ['CAMPUS_ADMIN', 'JIAOWU', 'SUPER_ADMIN'] } },
      { path: 'rule/template', name: 'RuleTemplateList', component: () => import('@/views/rule/RuleTemplateList.vue'), meta: { title: '规则模板', icon: 'Document', roles: ['SALARY_ADMIN', 'SUPER_ADMIN'] } },
      { path: 'rule/binding', name: 'RuleBindingList', component: () => import('@/views/rule/RuleBindingList.vue'), meta: { title: '教师规则绑定', icon: 'Connection', roles: ['SALARY_ADMIN', 'SUPER_ADMIN'] } },
      { path: 'rule/preview', name: 'RulePreview', component: () => import('@/views/rule/RulePreview.vue'), meta: { title: '规则预览', icon: 'View', roles: ['SALARY_ADMIN', 'SUPER_ADMIN'] } },
      { path: 'salary/calc', name: 'SalaryCalc', component: () => import('@/views/salary/Calc.vue'), meta: { title: '工资计算与预览', icon: 'Calculator', roles: ['SALARY_ADMIN', 'FINANCE', 'SUPER_ADMIN'] } },
      { path: 'salary/statement', name: 'SalaryStatementList', component: () => import('@/views/salary/StatementList.vue'), meta: { title: '工资单管理', icon: 'Tickets', roles: ['SALARY_ADMIN', 'FINANCE', 'SUPER_ADMIN'] } },
      { path: 'salary/detail', name: 'SalaryDetailList', component: () => import('@/views/salary/DetailList.vue'), meta: { title: '明细与快照', icon: 'List', roles: ['SALARY_ADMIN', 'FINANCE', 'SUPER_ADMIN'] } },
      { path: 'audit', name: 'AuditLogList', component: () => import('@/views/audit/AuditLogList.vue'), meta: { title: '审计日志', icon: 'Key', roles: ['SALARY_ADMIN', 'FINANCE', 'SUPER_ADMIN'] } }
    ]
  },
  { path: '/:pathMatch(.*)*', redirect: '/admin/dashboard' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 简易登录守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.public) return next()
  if (!token) return next('/admin/login')
  next()
})

export default router
