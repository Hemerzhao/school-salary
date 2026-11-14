-- 排课增强：不同星期不同上课时间、手工起始课次、班级年级
-- 仅新增列，不修改/删除任何已有数据
ALTER TABLE class_info ADD COLUMN grade_code TEXT DEFAULT '';
ALTER TABLE schedule_request ADD COLUMN day_times TEXT;
ALTER TABLE schedule_request ADD COLUMN start_lesson_no INTEGER;
