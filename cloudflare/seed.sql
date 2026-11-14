-- 初始数据 v2
INSERT INTO settings (key, value) VALUES
('salary_base_rate', '120'),        -- 1人成班：基础课时费（元/小时）
('salary_mid_rate', '150'),         -- 2-4人：增量基础课时费（元/小时）
('salary_extra_per_person', '10'),  -- 超过4人：每多1人加收（元/节课）
('mail_api_key', ''),               -- Brevo API Key（管理端可填写）
('mail_from_email', ''),            -- 发件邮箱
('mail_from_name', '教师工资统计系统');

INSERT INTO campus (id, name, address, status) VALUES
(1, '朝阳校区', '北京市朝阳区建国路88号', 1),
(2, '海淀校区', '北京市海淀区中关村大街1号', 1);

INSERT INTO teacher (id, name, employee_no, phone, email, campus_id, level, status) VALUES
(1, '张老师', 'T001', '13800138001', '', 1, 'P2', 1),
(2, '李老师', 'T002', '13800138002', '', 1, 'P1', 1),
(3, '王老师', 'T003', '13800138003', '', 2, 'P3', 1);

-- 管理员：admin / admin123
-- 教师：登录名=姓名全称，初始密码=姓名拼音小写+123456（如 张老师 → zhanglaoshi123456）
INSERT INTO sys_user (username, password, name, nickname, role, teacher_id, campus_id, status) VALUES
('admin', 'pbkdf2$100000$GVoBjEkzsrTogpcO7tIKAg==$77BiVfVFOCmTvOpIYHCwbBy7vWDwTgweEHz7dr/k+UQ=', 'admin', '管理员', 'ADMIN', NULL, NULL, 1),
('张老师', 'pbkdf2$100000$gcaTICJPGzRIq2EHElIwcw==$udOnJloGpJ+w4J73uSZ/GNNkEM9fYFrPAT1Mo1gJpqE=', '张老师', '张老师', 'TEACHER', 1, 1, 1),
('李老师', 'pbkdf2$100000$HRWyHjet8VsD3d8alpIMWg==$h225XcnuEGwpFv6NpUWuaYq06xFacasygwnxFariRv0=', '李老师', '李老师', 'TEACHER', 2, 1, 1),
('王老师', 'pbkdf2$100000$GdblCUDoTuGmrID2wauv2Q==$pUBB9ycV4YvkZduFJ/H5PRMI7Drc6Z2nnHeLZPZV3lg=', '王老师', '王老师', 'TEACHER', 3, 2, 1);
