-- migrate-020-lesson-label-teacher-initials.sql
-- 课次编号统一为：教师中文姓名拼音首字母（大写）+ D + 课次号，例如 LYYD17、PAND1。

UPDATE class_schedule
SET lesson_label = COALESCE((
  SELECT CASE t.name
    WHEN '蔡国章' THEN 'CGZ'
    WHEN '刘文婧' THEN 'LWJ'
    WHEN '潘安娜' THEN 'PAN'
    WHEN '赵洪颍' THEN 'ZHY'
    WHEN '梁玉叶' THEN 'LYY'
    WHEN '张栗钊' THEN 'ZLZ'
    WHEN '梅艳' THEN 'MY'
    WHEN '蒋勤勤' THEN 'JQQ'
    WHEN '周燕秦' THEN 'ZYQ'
    WHEN '潘潘' THEN 'PP'
    WHEN '王老师' THEN 'WLS'
    WHEN '李老师' THEN 'LLS'
    ELSE ''
  END
  FROM teacher t
  WHERE t.id = class_schedule.teacher_id
), '') || 'D' || lesson_no;

UPDATE attendance
SET lesson_label = COALESCE((
  SELECT CASE t.name
    WHEN '蔡国章' THEN 'CGZ'
    WHEN '刘文婧' THEN 'LWJ'
    WHEN '潘安娜' THEN 'PAN'
    WHEN '赵洪颍' THEN 'ZHY'
    WHEN '梁玉叶' THEN 'LYY'
    WHEN '张栗钊' THEN 'ZLZ'
    WHEN '梅艳' THEN 'MY'
    WHEN '蒋勤勤' THEN 'JQQ'
    WHEN '周燕秦' THEN 'ZYQ'
    WHEN '潘潘' THEN 'PP'
    WHEN '王老师' THEN 'WLS'
    WHEN '李老师' THEN 'LLS'
    ELSE ''
  END
  FROM teacher t
  WHERE t.id = attendance.teacher_id
), '') || 'D' || lesson_no;
