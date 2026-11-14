-- 教师端可自己填写班级（与管理员一致）：审核通过时自动建班级
-- 仅新增列，不影响已有申请数据
ALTER TABLE schedule_request ADD COLUMN new_class_name TEXT;
ALTER TABLE schedule_request ADD COLUMN new_class_code TEXT;
ALTER TABLE schedule_request ADD COLUMN new_students TEXT;
