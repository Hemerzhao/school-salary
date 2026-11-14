-- 排课增强：课次问题标注、排课来源、教师排课申请
-- 仅新增列/表，不改动已有数据

ALTER TABLE class_schedule ADD COLUMN issue_flag INTEGER NOT NULL DEFAULT 0;
ALTER TABLE class_schedule ADD COLUMN issue_note TEXT DEFAULT '';
ALTER TABLE class_schedule ADD COLUMN source TEXT DEFAULT 'ADMIN';
ALTER TABLE class_schedule ADD COLUMN created_by INTEGER;

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

CREATE INDEX IF NOT EXISTS idx_schedule_request_teacher ON schedule_request (teacher_id, status);
CREATE INDEX IF NOT EXISTS idx_schedule_request_status ON schedule_request (status);
