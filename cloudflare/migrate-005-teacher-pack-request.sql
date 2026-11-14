-- 教师端「套课」排课申请：一次提交多节课，管理员通过后批量生成课次
-- 仅新增列，不修改/删除任何已有数据
ALTER TABLE schedule_request ADD COLUMN week_dates TEXT;
ALTER TABLE schedule_request ADD COLUMN lesson_count INTEGER NOT NULL DEFAULT 1;
