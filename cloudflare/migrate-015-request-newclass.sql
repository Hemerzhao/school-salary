-- 迁移 015：教师新建班级申请时带上结构化字段
ALTER TABLE schedule_request ADD COLUMN new_grade_code TEXT;
ALTER TABLE schedule_request ADD COLUMN new_subject TEXT;
ALTER TABLE schedule_request ADD COLUMN new_class_type TEXT;
