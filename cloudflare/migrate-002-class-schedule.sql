-- 增量迁移：套课课表（只建新表，不改动任何已有数据，可安全在生产库执行）
CREATE TABLE IF NOT EXISTS class_schedule (
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
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_schedule_class ON class_schedule (class_id, planned_date);
CREATE INDEX IF NOT EXISTS idx_schedule_teacher ON class_schedule (teacher_id, planned_date);
