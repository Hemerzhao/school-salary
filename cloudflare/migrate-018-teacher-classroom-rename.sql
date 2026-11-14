-- ==========================================================
-- migrate-018-teacher-classroom-rename.sql
-- 1. 潘潘/王老师/李老师 班级换绑（账号已通过 API 创建）
-- 2. 教室只保留 9 间，4/5 号班从大教室修正
-- 3. 班级名统一为「年级代码-学科-班型」
-- 4. 学生刘娇先空出
-- ==========================================================

-- 1. 班级换绑老师
UPDATE class_info SET teacher_id = (SELECT id FROM teacher WHERE name = '潘潘')
 WHERE code IN ('P5Y-1V3', 'P4Y', 'P3Y');
UPDATE class_info SET teacher_id = (SELECT id FROM teacher WHERE name = '王老师')
 WHERE code IN ('W7E-1V3', 'W7E', 'W8E-JC');
UPDATE class_info SET teacher_id = (SELECT id FROM teacher WHERE name = '李老师')
 WHERE code = 'L2E-XB';

-- 同步 student_course 里的 teacher_id
UPDATE student_course SET teacher_id = (SELECT teacher_id FROM class_info WHERE class_info.id = student_course.class_id);

-- 2. 教室修正：文稿「教室4/教室5」= 大教室
UPDATE class_info SET classroom_id = (SELECT id FROM classroom WHERE name = '4号大教室')
 WHERE classroom_id = (SELECT id FROM classroom WHERE name = '4号小教室');
UPDATE class_info SET classroom_id = (SELECT id FROM classroom WHERE name = '5号大教室')
 WHERE classroom_id = (SELECT id FROM classroom WHERE name = '5号小教室');

-- 教室只保留 9 间：1/2/6/9/10/12号小教室 + 3/4/5号大教室
DELETE FROM classroom WHERE name NOT IN (
  '1号小教室','2号小教室','6号小教室','9号小教室','10号小教室','12号小教室',
  '3号大教室','4号大教室','5号大教室'
);

-- 3. 班级名统一为「年级代码-学科-班型」，同名班追加 -2
UPDATE class_info SET name = 'J2-语文-卓越班'   WHERE code = 'A8Y-PY';
UPDATE class_info SET name = 'J3-语文-1对3'     WHERE code = 'A9Y-1V3';
UPDATE class_info SET name = 'J0-语文-卓越班'   WHERE code = 'A6Y-PY';
UPDATE class_info SET name = 'J2-语文-基础班'   WHERE code = 'A8Y-JC';
UPDATE class_info SET name = 'J3-语文-1对3-2'   WHERE code = 'A3Y-1V3';
UPDATE class_info SET name = 'J0-语文-卓越班-2' WHERE code = 'A6Y-PY2';
UPDATE class_info SET name = 'P5-语文-1对3'     WHERE code = 'P5Y-1V3';
UPDATE class_info SET name = 'P4-语文-基础班'   WHERE code = 'P4Y';
UPDATE class_info SET name = 'P3-语文-基础班'   WHERE code = 'P3Y';
UPDATE class_info SET name = 'J2-数学-基础班'   WHERE code = 'Z2S-JC';
UPDATE class_info SET name = 'J0-数学-卓越班'   WHERE code = 'Z6S-PY';
UPDATE class_info SET name = 'J1-数学-1对1'     WHERE code = 'Z1S-1V1';
UPDATE class_info SET name = 'J1-数学-基础班'   WHERE code = 'Z1S-JC';
UPDATE class_info SET name = 'J3-数学-1对1'     WHERE code = 'Z3S-1V1';
UPDATE class_info SET name = 'J0-数学-小班'     WHERE code = 'C6S-XB';
UPDATE class_info SET name = 'P4-数学-基础班'   WHERE code = 'C4S';
UPDATE class_info SET name = 'P5-数学-基础班'   WHERE code = 'C5S';
UPDATE class_info SET name = 'J1-数学-基础班-2' WHERE code = 'C1S';
UPDATE class_info SET name = 'P1-英语-基础班'   WHERE code = 'AMY-E';
UPDATE class_info SET name = 'P1-英语-基础班-2' WHERE code = 'AMY-EP1';
UPDATE class_info SET name = 'J0-英语-1对3'     WHERE code = 'AMY-6E1V3';
UPDATE class_info SET name = 'P4-英语-1对1'     WHERE code = 'AMY-E1V1';
UPDATE class_info SET name = 'P5-英语-1对1'     WHERE code = 'J-E1V1';
UPDATE class_info SET name = 'P3-数学-卓越班'   WHERE code = 'W3S-PY';
UPDATE class_info SET name = 'P3-数学-基础班'   WHERE code = 'W3S-JC';
UPDATE class_info SET name = 'P4-数学-卓越班'   WHERE code = 'W4S-PY';
UPDATE class_info SET name = 'J2-英语-小班'     WHERE code = 'L2E-XB';
UPDATE class_info SET name = 'J1-英语-1对3'     WHERE code = 'W7E-1V3';
UPDATE class_info SET name = 'J1-英语-基础班'   WHERE code = 'W7E';
UPDATE class_info SET name = 'J2-英语-基础班'   WHERE code = 'W8E-JC';

-- 同步 student_course.course_name
UPDATE student_course SET course_name = (SELECT name FROM class_info WHERE class_info.id = student_course.class_id);

-- 4. 学生刘娇先空出（移出所有班级与套课，不建档）
DELETE FROM class_student WHERE name = '刘娇';
DELETE FROM student_course WHERE student_id = (SELECT id FROM student WHERE name = '刘娇');
DELETE FROM student WHERE name = '刘娇';
