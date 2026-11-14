-- 022：补充遗漏的周日班 52（潘安娜 J3-语文-1对3，周日 10:10）
-- 该班 11 月同样应从 11.1 起排，补 11.1 一节并把后续课次顺延 +1。
UPDATE class_schedule
SET lesson_no = lesson_no + 100000
WHERE class_id = 52
  AND planned_date >= '2026-11-01';

UPDATE class_schedule
SET lesson_no = lesson_no - 99999,
    lesson_label = rtrim(lesson_label, '0123456789') || CAST(lesson_no - 99999 AS TEXT),
    updated_at = datetime('now')
WHERE class_id = 52
  AND lesson_no >= 100000;

INSERT INTO class_schedule
  (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time,
   duration_minutes, classroom_id, status, source, created_at, updated_at)
SELECT class_id, teacher_id, 1, rtrim(lesson_label, '0123456789') || '1', '2026-11-01',
       planned_time, duration_minutes, classroom_id, 0, 'ADMIN', datetime('now'), datetime('now')
FROM class_schedule
WHERE class_id = 52
  AND planned_date = '2026-11-08'
  AND lesson_no = 2;
