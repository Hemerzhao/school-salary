-- 增量迁移：工资快照（只加列，不删任何数据，可安全在生产库执行）
-- 作用：审核通过时把课时费、人数费、小计冻结进 attendance 行，
--      之后修改工资规则、修改班级学生名单，都不会改变历史月份的工资。
ALTER TABLE attendance ADD COLUMN pay_rule TEXT;
ALTER TABLE attendance ADD COLUMN pay_unit_rate REAL;
ALTER TABLE attendance ADD COLUMN pay_hours_fee REAL;
ALTER TABLE attendance ADD COLUMN pay_head_fee REAL;
ALTER TABLE attendance ADD COLUMN pay_subtotal REAL;
ALTER TABLE attendance ADD COLUMN pay_teacher_name TEXT;
ALTER TABLE attendance ADD COLUMN pay_snapshot_at TEXT;
