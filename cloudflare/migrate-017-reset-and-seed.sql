-- ==========================================================
-- migrate-017-reset-and-seed.sql
-- 清空测试阶段打卡/课表/班级/学生，按新文稿重建班级和学生档案
-- ==========================================================

-- 1. 清空测试数据（保留 admin / teacher / classroom）
DELETE FROM attendance;
DELETE FROM class_schedule;
DELETE FROM student_course;
DELETE FROM student;
DELETE FROM class_info;


-- 2. 创建班级
INSERT INTO class_info (name, code, teacher_id, duration_minutes, grade_code, subject, class_type, classroom_id) VALUES
('安娜8年级语文培优班','A8Y-PY',(SELECT id FROM teacher WHERE name='潘安娜'),120,'J2','语文','培优班',(SELECT id FROM classroom WHERE name='6号小教室')),
('安娜9年级语文1V3','A9Y-1V3',(SELECT id FROM teacher WHERE name='潘安娜'),120,'J3','语文','1对3',(SELECT id FROM classroom WHERE name='6号小教室')),
('安娜6年级语文培优班','A6Y-PY',(SELECT id FROM teacher WHERE name='潘安娜'),120,'J0','语文','培优班',(SELECT id FROM classroom WHERE name='6号小教室')),
('安娜8年级语文基础班','A8Y-JC',(SELECT id FROM teacher WHERE name='潘安娜'),120,'J2','语文','基础班',(SELECT id FROM classroom WHERE name='6号小教室')),
('安娜初三语文1V3','A3Y-1V3',(SELECT id FROM teacher WHERE name='潘安娜'),120,'J3','语文','1对3',(SELECT id FROM classroom WHERE name='1号小教室')),
('安娜6年级语文培优班2','A6Y-PY2',(SELECT id FROM teacher WHERE name='潘安娜'),120,'J0','语文','培优班',(SELECT id FROM classroom WHERE name='5号小教室')),
('潘潘5年级语文1V3','P5Y-1V3',(SELECT id FROM teacher WHERE name='潘安娜'),120,'P5','语文','1对3',(SELECT id FROM classroom WHERE name='5号小教室')),
('潘潘4年级语文','P4Y',(SELECT id FROM teacher WHERE name='潘安娜'),120,'P4','语文','常规班',(SELECT id FROM classroom WHERE name='5号小教室')),
('潘潘3年级语文','P3Y',(SELECT id FROM teacher WHERE name='潘安娜'),120,'P3','语文','常规班',(SELECT id FROM classroom WHERE name='5号小教室')),
('赵老师初二数学基础班','Z2S-JC',(SELECT id FROM teacher WHERE name='赵洪颍'),120,'J2','数学','基础班',(SELECT id FROM classroom WHERE name='10号小教室')),
('赵老师6年级数学培优班','Z6S-PY',(SELECT id FROM teacher WHERE name='赵洪颍'),120,'J0','数学','培优班',(SELECT id FROM classroom WHERE name='10号小教室')),
('赵老师初一数学1V1','Z1S-1V1',(SELECT id FROM teacher WHERE name='赵洪颍'),120,'J1','数学','1对1',(SELECT id FROM classroom WHERE name='10号小教室')),
('赵老师初一数学基础班','Z1S-JC',(SELECT id FROM teacher WHERE name='赵洪颍'),120,'J1','数学','基础班',(SELECT id FROM classroom WHERE name='10号小教室')),
('赵老师初三数学1V1','Z3S-1V1',(SELECT id FROM teacher WHERE name='赵洪颍'),120,'J3','数学','1对1',(SELECT id FROM classroom WHERE name='1号小教室')),
('蔡老师6年级数学小班','C6S-XB',(SELECT id FROM teacher WHERE name='蔡国章'),130,'J0','数学','小班',(SELECT id FROM classroom WHERE name='1号小教室')),
('蔡老师4年级数学','C4S',(SELECT id FROM teacher WHERE name='蔡国章'),120,'P4','数学','常规班',(SELECT id FROM classroom WHERE name='4号小教室')),
('蔡老师5年级数学','C5S',(SELECT id FROM teacher WHERE name='蔡国章'),120,'P5','数学','常规班',(SELECT id FROM classroom WHERE name='4号小教室')),
('蔡老师初一数学','C1S',(SELECT id FROM teacher WHERE name='蔡国章'),120,'J1','数学','常规班',(SELECT id FROM classroom WHERE name='4号小教室')),
('AMY英语','AMY-E',(SELECT id FROM teacher WHERE name='梁玉叶'),90,'P1','英语','常规班',(SELECT id FROM classroom WHERE name='1号小教室')),
('AMY英语P1','AMY-EP1',(SELECT id FROM teacher WHERE name='梁玉叶'),120,'P1','英语','常规班',(SELECT id FROM classroom WHERE name='4号小教室')),
('AMY6年级英语1V3','AMY-6E1V3',(SELECT id FROM teacher WHERE name='梁玉叶'),120,'J0','英语','1对3',(SELECT id FROM classroom WHERE name='4号小教室')),
('AMY英语1V1','AMY-E1V1',(SELECT id FROM teacher WHERE name='梁玉叶'),120,'P4','英语','1对1',(SELECT id FROM classroom WHERE name='4号小教室')),
('蒋老师英语1V1','J-E1V1',(SELECT id FROM teacher WHERE name='蒋勤勤'),120,'P5','英语','1对1',(SELECT id FROM classroom WHERE name='2号小教室')),
('文婧3年级数学培优班','W3S-PY',(SELECT id FROM teacher WHERE name='刘文婧'),120,'P3','数学','培优班',(SELECT id FROM classroom WHERE name='6号小教室')),
('文婧3年级数学基础班','W3S-JC',(SELECT id FROM teacher WHERE name='刘文婧'),120,'P3','数学','基础班',(SELECT id FROM classroom WHERE name='6号小教室')),
('文婧4年级数学培优班','W4S-PY',(SELECT id FROM teacher WHERE name='刘文婧'),120,'P4','数学','培优班',(SELECT id FROM classroom WHERE name='6号小教室')),
('李老师初二英语小班','L2E-XB',(SELECT id FROM teacher WHERE name='周燕秦'),120,'J2','英语','小班',(SELECT id FROM classroom WHERE name='5号小教室')),
('7年级英语1V3王老师','W7E-1V3',(SELECT id FROM teacher WHERE name='梅艳'),120,'J1','英语','1对3',(SELECT id FROM classroom WHERE name='12号小教室')),
('7年级英语王老师','W7E',(SELECT id FROM teacher WHERE name='梅艳'),120,'J1','英语','常规班',(SELECT id FROM classroom WHERE name='12号小教室')),
('8年级英语基础班','W8E-JC',(SELECT id FROM teacher WHERE name='梅艳'),120,'J2','英语','基础班',(SELECT id FROM classroom WHERE name='12号小教室'));

-- 3. 创建学生档案
INSERT INTO student (name, grade_code, remark, status) VALUES
  ('任语琪','J2','',1),
  ('何羽菡','J1','',1),
  ('凌姝涵','J2','',1),
  ('刘哲诚','J2','',1),
  ('刘娇','P5','',1),
  ('刘宸睿','J2','',1),
  ('匡紫睿','P3','',1),
  ('姜瑞皓','P1','',1),
  ('孙瑞泽','P1','',1),
  ('张千珩','P3','',1),
  ('张恩熙','J0','',1),
  ('张梓瀓','J2','',1),
  ('张瀚宇','P3','',1),
  ('徐娅惜','J2','',1),
  ('徐若栩','P5','',1),
  ('徐谢晨','J1','',1),
  ('施雯浩','P4','',1),
  ('时铭博','J2','',1),
  ('李宗芮','J1','',1),
  ('杨依宸','P3','',1),
  ('杨可馨','J0','',1),
  ('杨梓彤','J1','',1),
  ('栾承熙','J0','',1),
  ('欧阳铭骏','J1','',1),
  ('毛歆悦','J1','',1),
  ('沈歆怡','J1','',1),
  ('潘子睿','J0','',1),
  ('王一凡','J1','',1),
  ('王世佳','J2','',1),
  ('王书阳','J1','',1),
  ('王诗蕴','J0','',1),
  ('王锦轩','J2','',1),
  ('白煜朗','J2','',1),
  ('盛思豫','J0','',1),
  ('石井爱佳','J0','',1),
  ('罗梓轩','J3','',1),
  ('苏子涵','J1','',1),
  ('袁浩宸','J2','',1),
  ('裴宸玮','P4','',1),
  ('邢瑞霖','P5','',1),
  ('郑旖旎','J2','',1),
  ('金书涵','J1','',1),
  ('闻芯宁','P4','',1),
  ('陆奕辰','J2','',1),
  ('陈懿轩','J2','',1),
  ('韩佳怡','J1','',1),
  ('韩沈欣','J2','',1),
  ('顾亦辰','J2','',1),
  ('鲁宸瑄','P5','',1);

-- 4. 学生套课记录（total_lessons 留 0，后续录入实际课次数）
INSERT INTO student_course (student_id, class_id, teacher_id, course_name, total_lessons, course_scope, grade_code) VALUES
  (
  (SELECT id FROM student WHERE name='顾亦辰'),
  (SELECT id FROM class_info WHERE code='A8Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-PY'),
  (SELECT name FROM class_info WHERE code='A8Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-PY')
),
  (
  (SELECT id FROM student WHERE name='凌姝涵'),
  (SELECT id FROM class_info WHERE code='A8Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-PY'),
  (SELECT name FROM class_info WHERE code='A8Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-PY')
),
  (
  (SELECT id FROM student WHERE name='袁浩宸'),
  (SELECT id FROM class_info WHERE code='A8Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-PY'),
  (SELECT name FROM class_info WHERE code='A8Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-PY')
),
  (
  (SELECT id FROM student WHERE name='张梓瀓'),
  (SELECT id FROM class_info WHERE code='A8Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-PY'),
  (SELECT name FROM class_info WHERE code='A8Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-PY')
),
  (
  (SELECT id FROM student WHERE name='徐娅惜'),
  (SELECT id FROM class_info WHERE code='A8Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-PY'),
  (SELECT name FROM class_info WHERE code='A8Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-PY')
),
  (
  (SELECT id FROM student WHERE name='刘宸睿'),
  (SELECT id FROM class_info WHERE code='A8Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-PY'),
  (SELECT name FROM class_info WHERE code='A8Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-PY')
),
  (
  (SELECT id FROM student WHERE name='罗梓轩'),
  (SELECT id FROM class_info WHERE code='A9Y-1V3'),
  (SELECT teacher_id FROM class_info WHERE code='A9Y-1V3'),
  (SELECT name FROM class_info WHERE code='A9Y-1V3'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A9Y-1V3')
),
  (
  (SELECT id FROM student WHERE name='石井爱佳'),
  (SELECT id FROM class_info WHERE code='A6Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A6Y-PY'),
  (SELECT name FROM class_info WHERE code='A6Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A6Y-PY')
),
  (
  (SELECT id FROM student WHERE name='杨可馨'),
  (SELECT id FROM class_info WHERE code='A6Y-PY'),
  (SELECT teacher_id FROM class_info WHERE code='A6Y-PY'),
  (SELECT name FROM class_info WHERE code='A6Y-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A6Y-PY')
),
  (
  (SELECT id FROM student WHERE name='时铭博'),
  (SELECT id FROM class_info WHERE code='A8Y-JC'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-JC'),
  (SELECT name FROM class_info WHERE code='A8Y-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-JC')
),
  (
  (SELECT id FROM student WHERE name='王锦轩'),
  (SELECT id FROM class_info WHERE code='A8Y-JC'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-JC'),
  (SELECT name FROM class_info WHERE code='A8Y-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-JC')
),
  (
  (SELECT id FROM student WHERE name='陈懿轩'),
  (SELECT id FROM class_info WHERE code='A8Y-JC'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-JC'),
  (SELECT name FROM class_info WHERE code='A8Y-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-JC')
),
  (
  (SELECT id FROM student WHERE name='郑旖旎'),
  (SELECT id FROM class_info WHERE code='A8Y-JC'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-JC'),
  (SELECT name FROM class_info WHERE code='A8Y-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-JC')
),
  (
  (SELECT id FROM student WHERE name='陆奕辰'),
  (SELECT id FROM class_info WHERE code='A8Y-JC'),
  (SELECT teacher_id FROM class_info WHERE code='A8Y-JC'),
  (SELECT name FROM class_info WHERE code='A8Y-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A8Y-JC')
),
  (
  (SELECT id FROM student WHERE name='罗梓轩'),
  (SELECT id FROM class_info WHERE code='A3Y-1V3'),
  (SELECT teacher_id FROM class_info WHERE code='A3Y-1V3'),
  (SELECT name FROM class_info WHERE code='A3Y-1V3'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A3Y-1V3')
),
  (
  (SELECT id FROM student WHERE name='徐若栩'),
  (SELECT id FROM class_info WHERE code='A6Y-PY2'),
  (SELECT teacher_id FROM class_info WHERE code='A6Y-PY2'),
  (SELECT name FROM class_info WHERE code='A6Y-PY2'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='A6Y-PY2')
),
  (
  (SELECT id FROM student WHERE name='施雯浩'),
  (SELECT id FROM class_info WHERE code='P5Y-1V3'),
  (SELECT teacher_id FROM class_info WHERE code='P5Y-1V3'),
  (SELECT name FROM class_info WHERE code='P5Y-1V3'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='P5Y-1V3')
),
  (
  (SELECT id FROM student WHERE name='裴宸玮'),
  (SELECT id FROM class_info WHERE code='P5Y-1V3'),
  (SELECT teacher_id FROM class_info WHERE code='P5Y-1V3'),
  (SELECT name FROM class_info WHERE code='P5Y-1V3'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='P5Y-1V3')
),
  (
  (SELECT id FROM student WHERE name='杨依宸'),
  (SELECT id FROM class_info WHERE code='P4Y'),
  (SELECT teacher_id FROM class_info WHERE code='P4Y'),
  (SELECT name FROM class_info WHERE code='P4Y'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='P4Y')
),
  (
  (SELECT id FROM student WHERE name='刘娇'),
  (SELECT id FROM class_info WHERE code='P3Y'),
  (SELECT teacher_id FROM class_info WHERE code='P3Y'),
  (SELECT name FROM class_info WHERE code='P3Y'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='P3Y')
),
  (
  (SELECT id FROM student WHERE name='刘哲诚'),
  (SELECT id FROM class_info WHERE code='Z2S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z2S-JC'),
  (SELECT name FROM class_info WHERE code='Z2S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z2S-JC')
),
  (
  (SELECT id FROM student WHERE name='韩沈欣'),
  (SELECT id FROM class_info WHERE code='Z2S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z2S-JC'),
  (SELECT name FROM class_info WHERE code='Z2S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z2S-JC')
),
  (
  (SELECT id FROM student WHERE name='白煜朗'),
  (SELECT id FROM class_info WHERE code='Z2S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z2S-JC'),
  (SELECT name FROM class_info WHERE code='Z2S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z2S-JC')
),
  (
  (SELECT id FROM student WHERE name='任语琪'),
  (SELECT id FROM class_info WHERE code='Z2S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z2S-JC'),
  (SELECT name FROM class_info WHERE code='Z2S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z2S-JC')
),
  (
  (SELECT id FROM student WHERE name='王世佳'),
  (SELECT id FROM class_info WHERE code='Z2S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z2S-JC'),
  (SELECT name FROM class_info WHERE code='Z2S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z2S-JC')
),
  (
  (SELECT id FROM student WHERE name='栾承熙'),
  (SELECT id FROM class_info WHERE code='Z6S-PY'),
  (SELECT teacher_id FROM class_info WHERE code='Z6S-PY'),
  (SELECT name FROM class_info WHERE code='Z6S-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z6S-PY')
),
  (
  (SELECT id FROM student WHERE name='王诗蕴'),
  (SELECT id FROM class_info WHERE code='Z6S-PY'),
  (SELECT teacher_id FROM class_info WHERE code='Z6S-PY'),
  (SELECT name FROM class_info WHERE code='Z6S-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z6S-PY')
),
  (
  (SELECT id FROM student WHERE name='徐谢晨'),
  (SELECT id FROM class_info WHERE code='Z1S-1V1'),
  (SELECT teacher_id FROM class_info WHERE code='Z1S-1V1'),
  (SELECT name FROM class_info WHERE code='Z1S-1V1'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z1S-1V1')
),
  (
  (SELECT id FROM student WHERE name='李宗芮'),
  (SELECT id FROM class_info WHERE code='Z1S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z1S-JC'),
  (SELECT name FROM class_info WHERE code='Z1S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z1S-JC')
),
  (
  (SELECT id FROM student WHERE name='杨梓彤'),
  (SELECT id FROM class_info WHERE code='Z1S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z1S-JC'),
  (SELECT name FROM class_info WHERE code='Z1S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z1S-JC')
),
  (
  (SELECT id FROM student WHERE name='王书阳'),
  (SELECT id FROM class_info WHERE code='Z1S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='Z1S-JC'),
  (SELECT name FROM class_info WHERE code='Z1S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z1S-JC')
),
  (
  (SELECT id FROM student WHERE name='罗梓轩'),
  (SELECT id FROM class_info WHERE code='Z3S-1V1'),
  (SELECT teacher_id FROM class_info WHERE code='Z3S-1V1'),
  (SELECT name FROM class_info WHERE code='Z3S-1V1'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='Z3S-1V1')
),
  (
  (SELECT id FROM student WHERE name='潘子睿'),
  (SELECT id FROM class_info WHERE code='C6S-XB'),
  (SELECT teacher_id FROM class_info WHERE code='C6S-XB'),
  (SELECT name FROM class_info WHERE code='C6S-XB'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='C6S-XB')
),
  (
  (SELECT id FROM student WHERE name='裴宸玮'),
  (SELECT id FROM class_info WHERE code='C4S'),
  (SELECT teacher_id FROM class_info WHERE code='C4S'),
  (SELECT name FROM class_info WHERE code='C4S'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='C4S')
),
  (
  (SELECT id FROM student WHERE name='邢瑞霖'),
  (SELECT id FROM class_info WHERE code='C5S'),
  (SELECT teacher_id FROM class_info WHERE code='C5S'),
  (SELECT name FROM class_info WHERE code='C5S'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='C5S')
),
  (
  (SELECT id FROM student WHERE name='鲁宸瑄'),
  (SELECT id FROM class_info WHERE code='C5S'),
  (SELECT teacher_id FROM class_info WHERE code='C5S'),
  (SELECT name FROM class_info WHERE code='C5S'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='C5S')
),
  (
  (SELECT id FROM student WHERE name='王一凡'),
  (SELECT id FROM class_info WHERE code='C1S'),
  (SELECT teacher_id FROM class_info WHERE code='C1S'),
  (SELECT name FROM class_info WHERE code='C1S'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='C1S')
),
  (
  (SELECT id FROM student WHERE name='刘娇'),
  (SELECT id FROM class_info WHERE code='C1S'),
  (SELECT teacher_id FROM class_info WHERE code='C1S'),
  (SELECT name FROM class_info WHERE code='C1S'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='C1S')
),
  (
  (SELECT id FROM student WHERE name='苏子涵'),
  (SELECT id FROM class_info WHERE code='C1S'),
  (SELECT teacher_id FROM class_info WHERE code='C1S'),
  (SELECT name FROM class_info WHERE code='C1S'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='C1S')
),
  (
  (SELECT id FROM student WHERE name='姜瑞皓'),
  (SELECT id FROM class_info WHERE code='AMY-E'),
  (SELECT teacher_id FROM class_info WHERE code='AMY-E'),
  (SELECT name FROM class_info WHERE code='AMY-E'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='AMY-E')
),
  (
  (SELECT id FROM student WHERE name='孙瑞泽'),
  (SELECT id FROM class_info WHERE code='AMY-EP1'),
  (SELECT teacher_id FROM class_info WHERE code='AMY-EP1'),
  (SELECT name FROM class_info WHERE code='AMY-EP1'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='AMY-EP1')
),
  (
  (SELECT id FROM student WHERE name='盛思豫'),
  (SELECT id FROM class_info WHERE code='AMY-6E1V3'),
  (SELECT teacher_id FROM class_info WHERE code='AMY-6E1V3'),
  (SELECT name FROM class_info WHERE code='AMY-6E1V3'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='AMY-6E1V3')
),
  (
  (SELECT id FROM student WHERE name='张恩熙'),
  (SELECT id FROM class_info WHERE code='AMY-6E1V3'),
  (SELECT teacher_id FROM class_info WHERE code='AMY-6E1V3'),
  (SELECT name FROM class_info WHERE code='AMY-6E1V3'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='AMY-6E1V3')
),
  (
  (SELECT id FROM student WHERE name='闻芯宁'),
  (SELECT id FROM class_info WHERE code='AMY-E1V1'),
  (SELECT teacher_id FROM class_info WHERE code='AMY-E1V1'),
  (SELECT name FROM class_info WHERE code='AMY-E1V1'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='AMY-E1V1')
),
  (
  (SELECT id FROM student WHERE name='王锦轩'),
  (SELECT id FROM class_info WHERE code='J-E1V1'),
  (SELECT teacher_id FROM class_info WHERE code='J-E1V1'),
  (SELECT name FROM class_info WHERE code='J-E1V1'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='J-E1V1')
),
  (
  (SELECT id FROM student WHERE name='王世佳'),
  (SELECT id FROM class_info WHERE code='J-E1V1'),
  (SELECT teacher_id FROM class_info WHERE code='J-E1V1'),
  (SELECT name FROM class_info WHERE code='J-E1V1'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='J-E1V1')
),
  (
  (SELECT id FROM student WHERE name='石井爱佳'),
  (SELECT id FROM class_info WHERE code='W3S-PY'),
  (SELECT teacher_id FROM class_info WHERE code='W3S-PY'),
  (SELECT name FROM class_info WHERE code='W3S-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W3S-PY')
),
  (
  (SELECT id FROM student WHERE name='杨可馨'),
  (SELECT id FROM class_info WHERE code='W3S-PY'),
  (SELECT teacher_id FROM class_info WHERE code='W3S-PY'),
  (SELECT name FROM class_info WHERE code='W3S-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W3S-PY')
),
  (
  (SELECT id FROM student WHERE name='杨依宸'),
  (SELECT id FROM class_info WHERE code='W3S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='W3S-JC'),
  (SELECT name FROM class_info WHERE code='W3S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W3S-JC')
),
  (
  (SELECT id FROM student WHERE name='张瀚宇'),
  (SELECT id FROM class_info WHERE code='W3S-JC'),
  (SELECT teacher_id FROM class_info WHERE code='W3S-JC'),
  (SELECT name FROM class_info WHERE code='W3S-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W3S-JC')
),
  (
  (SELECT id FROM student WHERE name='张千珩'),
  (SELECT id FROM class_info WHERE code='W4S-PY'),
  (SELECT teacher_id FROM class_info WHERE code='W4S-PY'),
  (SELECT name FROM class_info WHERE code='W4S-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W4S-PY')
),
  (
  (SELECT id FROM student WHERE name='匡紫睿'),
  (SELECT id FROM class_info WHERE code='W4S-PY'),
  (SELECT teacher_id FROM class_info WHERE code='W4S-PY'),
  (SELECT name FROM class_info WHERE code='W4S-PY'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W4S-PY')
),
  (
  (SELECT id FROM student WHERE name='施雯浩'),
  (SELECT id FROM class_info WHERE code='L2E-XB'),
  (SELECT teacher_id FROM class_info WHERE code='L2E-XB'),
  (SELECT name FROM class_info WHERE code='L2E-XB'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='L2E-XB')
),
  (
  (SELECT id FROM student WHERE name='毛歆悦'),
  (SELECT id FROM class_info WHERE code='W7E-1V3'),
  (SELECT teacher_id FROM class_info WHERE code='W7E-1V3'),
  (SELECT name FROM class_info WHERE code='W7E-1V3'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W7E-1V3')
),
  (
  (SELECT id FROM student WHERE name='何羽菡'),
  (SELECT id FROM class_info WHERE code='W7E'),
  (SELECT teacher_id FROM class_info WHERE code='W7E'),
  (SELECT name FROM class_info WHERE code='W7E'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W7E')
),
  (
  (SELECT id FROM student WHERE name='韩佳怡'),
  (SELECT id FROM class_info WHERE code='W7E'),
  (SELECT teacher_id FROM class_info WHERE code='W7E'),
  (SELECT name FROM class_info WHERE code='W7E'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W7E')
),
  (
  (SELECT id FROM student WHERE name='沈歆怡'),
  (SELECT id FROM class_info WHERE code='W7E'),
  (SELECT teacher_id FROM class_info WHERE code='W7E'),
  (SELECT name FROM class_info WHERE code='W7E'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W7E')
),
  (
  (SELECT id FROM student WHERE name='欧阳铭骏'),
  (SELECT id FROM class_info WHERE code='W7E'),
  (SELECT teacher_id FROM class_info WHERE code='W7E'),
  (SELECT name FROM class_info WHERE code='W7E'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W7E')
),
  (
  (SELECT id FROM student WHERE name='王书阳'),
  (SELECT id FROM class_info WHERE code='W7E'),
  (SELECT teacher_id FROM class_info WHERE code='W7E'),
  (SELECT name FROM class_info WHERE code='W7E'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W7E')
),
  (
  (SELECT id FROM student WHERE name='金书涵'),
  (SELECT id FROM class_info WHERE code='W7E'),
  (SELECT teacher_id FROM class_info WHERE code='W7E'),
  (SELECT name FROM class_info WHERE code='W7E'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W7E')
),
  (
  (SELECT id FROM student WHERE name='白煜朗'),
  (SELECT id FROM class_info WHERE code='W8E-JC'),
  (SELECT teacher_id FROM class_info WHERE code='W8E-JC'),
  (SELECT name FROM class_info WHERE code='W8E-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W8E-JC')
),
  (
  (SELECT id FROM student WHERE name='陈懿轩'),
  (SELECT id FROM class_info WHERE code='W8E-JC'),
  (SELECT teacher_id FROM class_info WHERE code='W8E-JC'),
  (SELECT name FROM class_info WHERE code='W8E-JC'),
  0,
  'SUBJECT',
  (SELECT grade_code FROM class_info WHERE code='W8E-JC')
);

-- 完成。课次(class_schedule)需按具体日期另行排课。