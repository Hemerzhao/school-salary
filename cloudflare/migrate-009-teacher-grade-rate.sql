-- 教师分年级课时费：每个老师 × 每个年级可单独设置基础课时费与增量课时费
-- 未配置时回落到全局工资规则；已冻结的历史工资记录不受影响
CREATE TABLE IF NOT EXISTS teacher_grade_rate (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  teacher_id       INTEGER NOT NULL,
  grade_code       TEXT    NOT NULL,
  base_rate        REAL,
  mid_rate         REAL,
  extra_per_person REAL,
  updated_at       TEXT,
  UNIQUE (teacher_id, grade_code)
);

CREATE INDEX IF NOT EXISTS idx_teacher_grade_rate_teacher ON teacher_grade_rate (teacher_id);
