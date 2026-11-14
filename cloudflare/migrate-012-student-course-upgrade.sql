-- 迁移 012：学生套课升级 —— 支持多学科课包 / 单学科 / 增补 / 退课
-- course_scope: PACKAGE 通用课包（多学科共享总课时）/ SUBJECT 指定学科
-- 课消仍通过 attendance.present_names 自动计算（请假不计），不改动历史数据

ALTER TABLE student_course ADD COLUMN course_scope TEXT DEFAULT 'SUBJECT';
ALTER TABLE student_course ADD COLUMN grade_code TEXT;

-- 历史默认：没有绑定班级的视为通用课包
UPDATE student_course SET course_scope =
  CASE WHEN class_id IS NULL OR class_id = 0 THEN 'PACKAGE' ELSE 'SUBJECT' END
WHERE course_scope IS NULL;
