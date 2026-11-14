-- 教师提交的学生名单变更申请（新增 / 移除学生），管理员审核后生效
CREATE TABLE IF NOT EXISTS student_request (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  teacher_id    INTEGER NOT NULL,
  class_id      INTEGER NOT NULL,
  add_names     TEXT,
  remove_names  TEXT,
  reason        TEXT,
  status        INTEGER NOT NULL DEFAULT 0,
  audit_by      INTEGER,
  audit_at      TEXT,
  audit_remark  TEXT,
  created_at    TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_student_request_status ON student_request (status, id);
CREATE INDEX IF NOT EXISTS idx_student_request_teacher ON student_request (teacher_id, id);
