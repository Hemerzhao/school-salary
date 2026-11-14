-- 教师工资统计系统 - D1 (SQLite) 表结构 v2
-- ⚠️ 仅用于「全新建库」。本文件含 DROP TABLE，在线上库执行会清空所有教师、课次与工资数据！
-- 线上增量升级请用 migrate-*.sql（只做 ALTER TABLE，不删数据），并先执行 backup.sh 备份。
DROP TABLE IF EXISTS email_log;
DROP TABLE IF EXISTS password_request;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS class_student;
DROP TABLE IF EXISTS class_info;
DROP TABLE IF EXISTS sys_user;
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS campus;
DROP TABLE IF EXISTS settings;

CREATE TABLE settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);

CREATE TABLE campus (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          TEXT    NOT NULL,
  address       TEXT,
  status        INTEGER NOT NULL DEFAULT 1,
  created_at    TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE teacher (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  name             TEXT    NOT NULL UNIQUE,
  employee_no      TEXT    NOT NULL UNIQUE,
  phone            TEXT,
  email            TEXT,
  campus_id        INTEGER NOT NULL DEFAULT 1,
  level            TEXT    NOT NULL DEFAULT 'P2',
  employment_type  TEXT    NOT NULL DEFAULT 'FULL',
  status           INTEGER NOT NULL DEFAULT 1,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE sys_user (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  username      TEXT    NOT NULL UNIQUE,
  password      TEXT    NOT NULL,
  name          TEXT    NOT NULL,
  nickname      TEXT,
  avatar        TEXT,
  role          TEXT    NOT NULL,
  phone         TEXT,
  email         TEXT,
  campus_id     INTEGER,
  teacher_id    INTEGER,
  status        INTEGER NOT NULL DEFAULT 1,
  created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE class_info (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  name             TEXT    NOT NULL,
  code             TEXT    NOT NULL,
  teacher_id       INTEGER NOT NULL,
  campus_id        INTEGER NOT NULL DEFAULT 1,
  duration_minutes INTEGER NOT NULL DEFAULT 120,
  status           INTEGER NOT NULL DEFAULT 1,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE class_student (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  class_id INTEGER NOT NULL,
  name     TEXT    NOT NULL,
  sort_no  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE attendance (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  teacher_id        INTEGER NOT NULL,
  campus_id         INTEGER NOT NULL DEFAULT 1,
  class_id          INTEGER,
  class_name        TEXT,
  lesson_no         INTEGER NOT NULL DEFAULT 1,
  lesson_label      TEXT,
  duration_minutes  INTEGER NOT NULL,
  student_count     INTEGER NOT NULL DEFAULT 0,
  leave_count       INTEGER NOT NULL DEFAULT 0,
  present_names     TEXT,
  leave_json        TEXT,
  audit_status      INTEGER NOT NULL DEFAULT 0,
  audit_by          INTEGER,
  audit_at          TEXT,
  audit_remark      TEXT,
  actual_start_time TEXT,
  actual_end_time   TEXT,
  email_status      TEXT,
  pay_rule          TEXT,
  pay_unit_rate     REAL,
  pay_hours_fee     REAL,
  pay_head_fee      REAL,
  pay_subtotal      REAL,
  pay_teacher_name  TEXT,
  pay_snapshot_at   TEXT,
  created_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_attendance_teacher ON attendance (teacher_id, actual_start_time);
CREATE INDEX idx_attendance_status ON attendance (audit_status);

CREATE TABLE password_request (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id      INTEGER NOT NULL,
  username     TEXT,
  name         TEXT,
  new_password TEXT NOT NULL,
  status       INTEGER NOT NULL DEFAULT 0,
  remark       TEXT,
  reviewed_by  TEXT,
  reviewed_at  TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE email_log (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  teacher_id   INTEGER,
  teacher_name TEXT,
  to_email     TEXT,
  subject      TEXT,
  content      TEXT,
  status       TEXT,
  error        TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_class_student ON class_student (class_id);
CREATE INDEX idx_class_teacher ON class_info (teacher_id);

-- 套课课表：管理员按「上课时间 + 学生名单」排好一整套课次，推送到教师端
CREATE TABLE class_schedule (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  class_id         INTEGER NOT NULL,
  teacher_id       INTEGER NOT NULL,
  lesson_no        INTEGER NOT NULL,
  lesson_label     TEXT,
  planned_date     TEXT    NOT NULL,
  planned_time     TEXT    NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 120,
  student_names    TEXT,
  status           INTEGER NOT NULL DEFAULT 0,
  attendance_id    INTEGER,
  remark           TEXT,
  issue_flag       INTEGER NOT NULL DEFAULT 0,
  issue_note       TEXT DEFAULT '',
  source           TEXT DEFAULT 'ADMIN',
  created_by       INTEGER,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_schedule_class ON class_schedule (class_id, planned_date);
CREATE INDEX idx_schedule_teacher ON class_schedule (teacher_id, planned_date);

-- 教师提交的排课申请（管理员审核后生成课次）
CREATE TABLE IF NOT EXISTS schedule_request (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  teacher_id       INTEGER NOT NULL,
  class_id         INTEGER NOT NULL,
  planned_date     TEXT    NOT NULL,
  planned_time     TEXT    NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 120,
  remark           TEXT,
  status           INTEGER NOT NULL DEFAULT 0,
  audit_by         INTEGER,
  audit_at         TEXT,
  audit_remark     TEXT,
  schedule_id      INTEGER,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);
