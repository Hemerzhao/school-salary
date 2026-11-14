-- migrate-019-schedule-to-winter.sql
-- 28 个班排课至 2027-01-31（寒假前）；AMY 三个班按文稿 D 号锚定

-- 0. 合并重复班：A3Y-1V3→A9Y-1V3、A6Y-PY2→A6Y-PY（同老师同学生同时间）
DELETE FROM student_course WHERE class_id IN (SELECT id FROM class_info WHERE code IN ('A3Y-1V3','A6Y-PY2'));
DELETE FROM class_student WHERE class_id IN (SELECT id FROM class_info WHERE code IN ('A3Y-1V3','A6Y-PY2'));
DELETE FROM class_info WHERE code IN ('A3Y-1V3','A6Y-PY2');

-- A8Y-PY（潘安娜 / 6号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-06', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-13', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-20', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-27', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-04', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-11', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-18', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-25', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-01', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-08', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-15', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-22', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-29', '18:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-PY';

-- A9Y-1V3（潘安娜 / 6号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A9Y-1V3';

-- A6Y-PY（潘安娜 / 6号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A6Y-PY';

-- A8Y-JC（潘安娜 / 6号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '15:50', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'A8Y-JC';

-- P5Y-1V3（潘潘 / 5号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '09:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P5Y-1V3';

-- P4Y（潘潘 / 5号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P4Y';

-- P3Y（潘潘 / 5号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'P3Y';

-- Z2S-JC（赵洪颍 / 10号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z2S-JC';

-- Z6S-PY（赵洪颍 / 10号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z6S-PY';

-- Z1S-1V1（赵洪颍 / 10号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-1V1';

-- Z1S-JC（赵洪颍 / 10号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z1S-JC';

-- Z3S-1V1（赵洪颍 / 1号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '13:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'Z3S-1V1';

-- C6S-XB（蔡国章 / 1号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '15:40', 130, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C6S-XB';

-- C4S（蔡国章 / 4号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-06', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-13', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-20', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-27', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-04', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-11', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-18', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-25', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-01', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-08', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-15', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-22', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-29', '18:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C4S';

-- C5S（蔡国章 / 4号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-06', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-13', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-20', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-27', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-04', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-11', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-18', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-25', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-01', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-08', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-15', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-22', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-29', '15:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C5S';

-- C1S（蔡国章 / 4号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'C1S';

-- AMY-E（梁玉叶 / 1号小教室，14 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 16, c.code || '16', '2026-10-31', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 17, c.code || '17', '2026-11-07', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 18, c.code || '18', '2026-11-14', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 19, c.code || '19', '2026-11-21', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 20, c.code || '20', '2026-11-28', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 21, c.code || '21', '2026-12-05', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 22, c.code || '22', '2026-12-12', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 23, c.code || '23', '2026-12-19', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 24, c.code || '24', '2026-12-26', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 25, c.code || '25', '2027-01-02', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 26, c.code || '26', '2027-01-09', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 27, c.code || '27', '2027-01-16', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 28, c.code || '28', '2027-01-23', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 29, c.code || '29', '2027-01-30', '10:00', 90, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E';

-- AMY-EP1（梁玉叶 / 4号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '13:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-EP1';

-- AMY-6E1V3（梁玉叶 / 4号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 18, c.code || '18', '2026-11-07', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 19, c.code || '19', '2026-11-14', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 20, c.code || '20', '2026-11-21', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 21, c.code || '21', '2026-11-28', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 22, c.code || '22', '2026-12-05', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 23, c.code || '23', '2026-12-12', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 24, c.code || '24', '2026-12-19', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 25, c.code || '25', '2026-12-26', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 26, c.code || '26', '2027-01-02', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 27, c.code || '27', '2027-01-09', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 28, c.code || '28', '2027-01-16', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 29, c.code || '29', '2027-01-23', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 30, c.code || '30', '2027-01-30', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-6E1V3';

-- AMY-E1V1（梁玉叶 / 4号大教室，14 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2026-11-01', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2026-11-08', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 14, c.code || '14', '2026-11-15', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 15, c.code || '15', '2026-11-22', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 16, c.code || '16', '2026-11-29', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 17, c.code || '17', '2026-12-06', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 18, c.code || '18', '2026-12-13', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 19, c.code || '19', '2026-12-20', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 20, c.code || '20', '2026-12-27', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 21, c.code || '21', '2027-01-03', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 22, c.code || '22', '2027-01-10', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 23, c.code || '23', '2027-01-17', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 24, c.code || '24', '2027-01-24', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 25, c.code || '25', '2027-01-31', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'AMY-E1V1';

-- J-E1V1（蒋勤勤 / 2号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '10:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'J-E1V1';

-- W3S-PY（刘文婧 / 6号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '10:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-PY';

-- W3S-JC（刘文婧 / 6号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W3S-JC';

-- W4S-PY（刘文婧 / 6号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '15:30', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W4S-PY';

-- L2E-XB（李老师 / 5号大教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '08:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'L2E-XB';

-- W7E-1V3（王老师 / 12号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-07', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-14', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-21', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-28', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-05', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-12', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-19', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-26', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-02', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-09', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-16', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-23', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-30', '15:10', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E-1V3';

-- W7E（王老师 / 12号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '13:00', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W7E';

-- W8E-JC（王老师 / 12号小教室，13 节）
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 1, c.code || '1', '2026-11-08', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 2, c.code || '2', '2026-11-15', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 3, c.code || '3', '2026-11-22', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 4, c.code || '4', '2026-11-29', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 5, c.code || '5', '2026-12-06', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 6, c.code || '6', '2026-12-13', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 7, c.code || '7', '2026-12-20', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 8, c.code || '8', '2026-12-27', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 9, c.code || '9', '2027-01-03', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 10, c.code || '10', '2027-01-10', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 11, c.code || '11', '2027-01-17', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 12, c.code || '12', '2027-01-24', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
INSERT INTO class_schedule (class_id, teacher_id, lesson_no, lesson_label, planned_date, planned_time, duration_minutes, classroom_id, student_names, status, source)
SELECT c.id, c.teacher_id, 13, c.code || '13', '2027-01-31', '08:20', 120, c.classroom_id,
       (SELECT GROUP_CONCAT(name, '、') FROM class_student WHERE class_id = c.id), 0, 'ADMIN'
FROM class_info c WHERE c.code = 'W8E-JC';
