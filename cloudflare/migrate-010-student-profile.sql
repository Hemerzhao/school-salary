-- 学生档案 + 学生套课：记录学生上过多少课、对应老师、套课剩余课时
-- 出勤数据直接复用教师打卡（attendance），不复制、不改动历史打卡与工资
CREATE TABLE IF NOT EXISTS student (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT    NOT NULL,
  grade_code  TEXT DEFAULT '',
  phone       TEXT,
  remark      TEXT,
  share_token TEXT,
  status      INTEGER NOT NULL DEFAULT 1,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS student_course (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id    INTEGER NOT NULL,
  class_id      INTEGER,
  teacher_id    INTEGER,
  course_name   TEXT,
  total_lessons INTEGER NOT NULL DEFAULT 0,
  created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_student_name ON student (name);
CREATE INDEX IF NOT EXISTS idx_student_share ON student (share_token);
CREATE INDEX IF NOT EXISTS idx_student_course_student ON student_course (student_id);
CREATE INDEX IF NOT EXISTS idx_student_course_class ON student_course (class_id);
