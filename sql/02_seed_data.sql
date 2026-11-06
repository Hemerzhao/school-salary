-- ========================================================
-- 教师工资统计系统 - 初始数据
-- ========================================================

USE school_salary;

-- 校区
INSERT INTO campus (id, name, address, wifi_ssid, gps_center, gps_radius_km) VALUES
(1, '朝阳校区', '北京市朝阳区建国路88号', 'CampusA-WiFi', '39.9042,116.4074', 1.5),
(2, '海淀校区', '北京市海淀区中关村大街1号', 'CampusB-WiFi', '39.9842,116.3074', 1.5);

-- 课程类型
INSERT INTO course (id, name, course_type, default_duration_min) VALUES
(1, 'K12英语基础班', 'K12', 120),
(2, '少儿编程启蒙', '少儿编程', 120),
(3, '创意美术周末班', '美术', 90);

-- 班级
INSERT INTO class_info (id, name, campus_id, course_type, grade, max_students) VALUES
(1, '朝阳K12英语A班', 1, 'K12', '初中', 30),
(2, '朝阳编程启蒙B班', 1, '少儿编程', '小学3-4年级', 25),
(3, '海淀美术周末班', 2, '美术', '小学', 20);

-- 教师
INSERT INTO teacher (id, name, phone, employee_no, campus_id, level, employment_type, bank_account) VALUES
(1, '张老师', '13800138001', 'T001', 1, 'T2', 'FULL', '6222****0001'),
(2, '李老师', '13800138002', 'T002', 1, 'T1', 'PART', '6222****0002'),
(3, '王老师', '13800138003', 'T003', 2, 'T3', 'FULL', '6222****0003');

-- 规则模板
INSERT INTO rule_template (id, name, formula_template, param_schema, supported_dimensions, description) VALUES
(1, '标准课时费模板', 'base_rate * hours + headcount_amount + course_bonus + level_bonus + time_slot_subsidy',
'[
  {"name":"base_rate","type":"number","default":120,"description":"基础每课时费用(元)，1课时=1小时"},
  {"name":"headcount_tiers","type":"json","default":[{"base_count":15,"extra_per_person":5},{"base_count":25,"extra_per_person":8}],"description":"人头分段累加"},
  {"name":"course_type_coefs","type":"json","default":{"K12":1.0,"少儿编程":1.2,"美术":0.9},"description":"课程类型系数"},
  {"name":"teacher_level_coefs","type":"json","default":{"T1":1.0,"T2":1.2,"T3":1.5,"Senior":2.0},"description":"教师等级系数"},
  {"name":"time_slot_subsidies","type":"json","default":{"weekend":20,"evening":15},"description":"时段补贴(取单一最高档)"}
]',
'["hours","headcount_tiers","course_type_coefs","teacher_level_coefs","time_slot_subsidy"]',
'K12标准课时费模板');

-- 规则版本 v1.0
INSERT INTO rule_version (id, template_id, version_no, formula, default_params, effective_from, effective_to, status, change_log) VALUES
(1, 1, 'v1.0',
'base_rate * hours + headcount_amount + course_bonus + level_bonus + time_slot_subsidy',
'{"base_rate":120,"headcount_tiers":[{"base_count":15,"extra_per_person":5},{"base_count":25,"extra_per_person":8}],"course_type_coefs":{"K12":1.0,"少儿编程":1.2,"美术":0.9},"teacher_level_coefs":{"T1":1.0,"T2":1.2,"T3":1.5,"Senior":2.0},"time_slot_subsidies":{"weekend":20,"evening":15}}',
'2026-01-01', NULL, 2, '初始版本');

-- 教师规则绑定（全部用 v1.0）
INSERT INTO teacher_rule_binding (teacher_id, rule_version_id, effective_from, param_overrides, priority, created_by) VALUES
(1, 1, '2026-01-01', '{"base_rate":150,"headcount_tiers":[{"base_count":10,"extra_per_person":6},{"base_count":20,"extra_per_person":10}]}', 100, 1),
(2, 1, '2026-01-01', NULL, 100, 1),
(3, 1, '2026-01-01', '{"base_rate":200}', 100, 1);

-- ========================================================
-- 后台用户（密码都是 admin123 BCrypt）
-- $2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2
-- 这个hash对应明文 admin123
-- ========================================================

INSERT INTO sys_user (username, password, name, role, campus_id, teacher_id) VALUES
('super',    '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '超级管理员', 'SUPER_ADMIN', NULL, NULL),
('salary',   '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '计费管理员', 'SALARY_ADMIN', NULL, NULL),
('finance',  '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '财务',       'FINANCE',      NULL, NULL),
('jiaowu',   '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '教务',       'JIAOWU',       NULL, NULL),
('campus1',  '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '朝阳校区管理员', 'CAMPUS_ADMIN', 1, NULL),
('teacher1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张老师',     'TEACHER',      1, 1),
('teacher2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李老师',     'TEACHER',      1, 2),
('teacher3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王老师',     'TEACHER',      2, 3);

-- 样例排课
INSERT INTO schedule (teacher_id, class_id, course_id, campus_id, start_time, end_time, expected_duration, schedule_type, status, created_by) VALUES
(1, 1, 1, 1, '2026-11-06 09:00:00', '2026-11-06 11:00:00', 120, 'NORMAL', 1, 1),
(1, 2, 2, 1, '2026-11-07 14:00:00', '2026-11-07 16:00:00', 120, 'NORMAL', 1, 1),
(2, 2, 2, 1, '2026-11-08 18:30:00', '2026-11-08 20:00:00', 90,  'NORMAL', 1, 1),
(3, 3, 3, 2, '2026-11-09 10:00:00', '2026-11-09 12:00:00', 120, 'TRIAL',  1, 1);

-- 样例打卡(已审核)
INSERT INTO attendance (schedule_id, teacher_id, campus_id, actual_start_time, actual_end_time, duration_minutes, student_count, leave_count, absent_count, audit_status, audit_by, audit_at) VALUES
(1, 1, 1, '2026-11-06 09:02:00', '2026-11-06 11:00:00', 118, 28, 2, 0, 1, 5, '2026-11-06 12:00:00'),
(2, 1, 1, '2026-11-07 14:05:00', '2026-11-07 16:03:00', 118, 22, 1, 0, 1, 5, '2026-11-07 17:00:00'),
(3, 2, 1, '2026-11-08 18:28:00', '2026-11-08 19:58:00', 90,  16, 0, 0, 1, 5, '2026-11-08 20:30:00');
