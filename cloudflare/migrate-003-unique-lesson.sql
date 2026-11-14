-- 加固：同一班级的班次号唯一，防止两名管理员并发排课产生重复班次号
-- 仅新增索引，不改动任何已有数据；执行前已核对线上无重复班次号
CREATE UNIQUE INDEX IF NOT EXISTS idx_class_schedule_lesson
  ON class_schedule (class_id, lesson_no);
