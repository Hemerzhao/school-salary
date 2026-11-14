-- 021：按文稿的每周固定时段补齐 11 月自然月课程
-- 说明：周一到周五/周六班在 11 月已完整（周五 11.6/13/20/27，周六 11.7/14/21/28），
--       周日班此前从 11.8 起排，缺少 11.1（周日）。本迁移为 9 个周日班补 11.1 一节，
--       并把该班 11.1 之后的课次顺延 +1，保持课次连续、编号仍为「姓名首字母 + D + 课次号」。
-- 影响班级：53 J0-语文-卓越班、54 J2-语文-基础班、61 J0-数学-卓越班、64 J3-数学-1对1、
--           65 J0-数学-小班、73 P5-英语-1对1、77 J2-英语-小班、79 J1-英语-基础班、80 J2-英语-基础班
-- 梁玉叶周日班（72）已有 11.1，无需改动；梁玉叶周六班（69）10.31 = LYYD16、11.7 = LYYD17 保持不变。

-- 1) 先整体上移，避免 (class_id, lesson_no) 唯一约束冲突
UPDATE class_schedule
SET lesson_no = lesson_no + 100000
WHERE class_id IN (53, 54, 61, 64, 65, 73, 77, 79, 80)
  AND planned_date >= '2026-11-01';

-- 2) 回落为原课次 +1，并同步重写课次编号
UPDATE class_schedule
SET lesson_no = lesson_no - 99999,
    lesson_label = rtrim(lesson_label, '0123456789') || CAST(lesson_no - 99999 AS TEXT),
    updated_at = datetime('now')
WHERE class_id IN (53, 54, 61, 64, 65, 73, 77, 79, 80)
  AND lesson_no >= 100000;

-- 3) 为每个周日班补 11.1 一节，时间/时长/教室沿用该班 11.8（现为第 2 节）的配置
INSERT INTO class_schedule
  (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time,
   duration_minutes, classroom_id, status, source, created_at, updated_at)
SELECT class_id, teacher_id, 1, rtrim(lesson_label, '0123456789') || '1', '2026-11-01',
       planned_time, duration_minutes, classroom_id, 0, 'ADMIN', datetime('now'), datetime('now')
FROM class_schedule
WHERE class_id IN (53, 54, 61, 64, 65, 73, 77, 79, 80)
  AND planned_date = '2026-11-08'
  AND lesson_no = 2;
