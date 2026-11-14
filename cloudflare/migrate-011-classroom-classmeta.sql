-- 迁移 011：教室管理 + 班级名称结构化 + 批量重命名历史班级
-- 仅新增列/新表；历史班级按规则从 Gx-学科-班型 → 新格式自动迁移

-- 教室表（小教室 / 大教室）
CREATE TABLE IF NOT EXISTS classroom (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL UNIQUE,       -- 如 "小教室1" / "大教室1"
  size        TEXT NOT NULL DEFAULT 'SMALL', -- SMALL / LARGE
  status      INTEGER NOT NULL DEFAULT 1, -- 1 使用中 0 停用
  remark      TEXT,
  created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_classroom_size ON classroom (size, status);

-- 班级名称结构化：年级 / 学科 / 班型，历史班级自动拆分
ALTER TABLE class_info ADD COLUMN subject TEXT;
ALTER TABLE class_info ADD COLUMN class_type TEXT;   -- 基础班 / 卓越班 / 一对一 等
ALTER TABLE class_info ADD COLUMN classroom_id INTEGER;

-- 课次绑定教室（支持教室冲突检测）
ALTER TABLE class_schedule ADD COLUMN classroom_id INTEGER;

-- 历史班级 grade_code 自动回填（5+4 学制）
UPDATE class_info SET grade_code =
  CASE
    WHEN substr(name,1,2)='K0' OR name LIKE '%小班%' THEN 'K0'
    WHEN substr(name,1,2)='K1' OR name LIKE '%中班%' THEN 'K1'
    WHEN substr(name,1,2)='K2' OR name LIKE '%大班%' THEN 'K2'
    WHEN substr(name,1,2)='P0' OR name LIKE '%幼小衔接%' THEN 'P0'
    WHEN substr(name,1,2)='P1' OR name LIKE '%一年级%' THEN 'P1'
    WHEN substr(name,1,2)='P2' OR name LIKE '%二年级%' THEN 'P2'
    WHEN substr(name,1,2)='P3' OR name LIKE '%三年级%' THEN 'P3'
    WHEN substr(name,1,2)='P4' OR name LIKE '%四年级%' THEN 'P4'
    WHEN substr(name,1,2)='P5' OR name LIKE '%五年级%' THEN 'P5'
    WHEN substr(name,1,2)='J0' OR name LIKE '%小初衔接%' THEN 'J0'
    WHEN substr(name,1,2)='J1' OR name LIKE '%初一%' THEN 'J1'
    WHEN substr(name,1,2)='J2' OR name LIKE '%初二%' THEN 'J2'
    WHEN substr(name,1,2)='J3' OR name LIKE '%初三%' THEN 'J3'
    WHEN substr(name,1,2)='H0' OR name LIKE '%初高衔接%' THEN 'H0'
    WHEN substr(name,1,2)='H1' OR name LIKE '%高一%' THEN 'H1'
    WHEN substr(name,1,2)='H2' OR name LIKE '%高二%' THEN 'H2'
    WHEN substr(name,1,2)='H3' OR name LIKE '%高三%' THEN 'H3'
    WHEN substr(name,1,2)='G1' THEN 'P1'
    WHEN substr(name,1,2)='G2' THEN 'P2'
    WHEN substr(name,1,2)='G3' THEN 'P3'
    WHEN substr(name,1,2)='G4' THEN 'P4'
    WHEN substr(name,1,2)='G5' THEN 'P5'
    WHEN substr(name,1,2)='G6' THEN 'J0'
    WHEN substr(name,1,2)='G7' THEN 'J1'
    WHEN substr(name,1,2)='G8' THEN 'J2'
    WHEN substr(name,1,2)='G9' THEN 'J3'
    ELSE ''
  END
WHERE grade_code IS NULL OR grade_code = '';

-- 从旧名称里拆出学科与班型（例 "G8-语文-基础班"）
UPDATE class_info SET
  subject = COALESCE(NULLIF(subject, ''),
    CASE
      WHEN name LIKE '%语文%' THEN '语文'
      WHEN name LIKE '%数学%' THEN '数学'
      WHEN name LIKE '%英语%' THEN '英语'
      WHEN name LIKE '%物理%' THEN '物理'
      WHEN name LIKE '%化学%' THEN '化学'
      WHEN name LIKE '%生物%' THEN '生物'
      WHEN name LIKE '%历史%' THEN '历史'
      WHEN name LIKE '%地理%' THEN '地理'
      WHEN name LIKE '%政治%' OR name LIKE '%道法%' THEN '政治'
      ELSE ''
    END),
  class_type = COALESCE(NULLIF(class_type, ''),
    CASE
      WHEN name LIKE '%卓越班%' THEN '卓越班'
      WHEN name LIKE '%尖子班%' THEN '尖子班'
      WHEN name LIKE '%冲刺班%' THEN '冲刺班'
      WHEN name LIKE '%一对一%' THEN '一对一'
      WHEN name LIKE '%一对二%' THEN '一对二'
      WHEN name LIKE '%精品班%' THEN '精品班'
      WHEN name LIKE '%提高班%' THEN '提高班'
      ELSE '基础班'
    END);

-- 重命名为统一格式 "J2-语文-基础班"（grade_code-学科-班型）
UPDATE class_info SET name =
  CASE
    WHEN grade_code IS NOT NULL AND grade_code <> '' AND subject IS NOT NULL AND subject <> '' AND class_type IS NOT NULL AND class_type <> ''
      THEN grade_code || '-' || subject || '-' || class_type
    ELSE name
  END
WHERE (grade_code IS NOT NULL AND grade_code <> '')
  AND (subject IS NOT NULL AND subject <> '')
  AND (class_type IS NOT NULL AND class_type <> '');
