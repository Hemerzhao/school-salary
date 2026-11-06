-- ========================================================
-- 教师工资统计系统 - 数据库初始化脚本
-- MySQL 8.0 | utf8mb4 | InnoDB
-- 版本：v1.1 (2026-11-06)
-- ========================================================

CREATE DATABASE IF NOT EXISTS school_salary DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE school_salary;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ==================== 组织架构 ====================

DROP TABLE IF EXISTS campus;
CREATE TABLE campus (
    id              BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(64)     NOT NULL COMMENT '校区名称',
    address         VARCHAR(255)    DEFAULT NULL,
    wifi_ssid       VARCHAR(64)     DEFAULT NULL COMMENT '校区WiFi SSID，用于打卡定位校验',
    gps_center      VARCHAR(64)     DEFAULT NULL COMMENT 'GPS中心点 如: 39.9042,116.4074',
    gps_radius_km   DECIMAL(6,2)   DEFAULT 1.0 COMMENT '打卡允许GPS半径(公里)',
    status          TINYINT         NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status(status)
) ENGINE=InnoDB COMMENT '校区';

DROP TABLE IF EXISTS teacher;
CREATE TABLE teacher (
    id              BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(32)     NOT NULL,
    phone           VARCHAR(20)     DEFAULT NULL,
    employee_no     VARCHAR(32)     NOT NULL COMMENT '工号',
    openid          VARCHAR(64)     DEFAULT NULL COMMENT '微信openid，教师端登录用',
    campus_id       BIGINT          NOT NULL COMMENT '主校区',
    level           VARCHAR(16)     NOT NULL DEFAULT 'T1' COMMENT '教师等级 T1/T2/T3/Senior',
    employment_type VARCHAR(16)     NOT NULL DEFAULT 'FULL' COMMENT 'FULL全职/PART兼职',
    status          TINYINT         NOT NULL DEFAULT 1 COMMENT '1在职 0离职',
    bank_account    VARCHAR(64)     DEFAULT NULL COMMENT '银行卡号(AES加密)',
    id_card         VARCHAR(64)     DEFAULT NULL COMMENT '身份证号(AES加密)',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_employee_no(employee_no),
    INDEX idx_campus(campus_id),
    INDEX idx_openid(openid)
) ENGINE=InnoDB COMMENT '教师';

DROP TABLE IF EXISTS class_info;
CREATE TABLE class_info (
    id              BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(64)     NOT NULL,
    campus_id       BIGINT          NOT NULL,
    course_type     VARCHAR(32)     NOT NULL COMMENT '课程类型 K12/少儿编程/美术...',
    grade           VARCHAR(16)     DEFAULT NULL COMMENT '年级',
    max_students    INT             NOT NULL DEFAULT 30,
    status          TINYINT         NOT NULL DEFAULT 1,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_campus(campus_id)
) ENGINE=InnoDB COMMENT '班级';

DROP TABLE IF EXISTS course;
CREATE TABLE course (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(64)     NOT NULL,
    course_type         VARCHAR(32)     NOT NULL COMMENT '课程类型',
    default_duration_min INT            NOT NULL DEFAULT 120 COMMENT '默认单课时总时长(分钟)',
    status              TINYINT         NOT NULL DEFAULT 1,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT '课程';

-- ==================== 排课与打卡 ====================

DROP TABLE IF EXISTS schedule;
CREATE TABLE schedule (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    teacher_id          BIGINT          NOT NULL,
    class_id            BIGINT          NOT NULL,
    course_id           BIGINT          NOT NULL,
    campus_id           BIGINT          NOT NULL,
    start_time          DATETIME        NOT NULL COMMENT '计划开始',
    end_time            DATETIME        NOT NULL COMMENT '计划结束',
    expected_duration   INT             NOT NULL COMMENT '计划时长(分钟)',
    schedule_type       VARCHAR(16)     NOT NULL DEFAULT 'NORMAL' COMMENT 'NORMAL正常(计入工资)/TRIAL试听(不计)/SUPPLEMENT补课(不计)',
    status              TINYINT         NOT NULL DEFAULT 1 COMMENT '1待上 2进行中 3已完成 4已取消',
    created_by          BIGINT          DEFAULT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_teacher_time(teacher_id, start_time),
    INDEX idx_campus_time(campus_id, start_time),
    INDEX idx_class(class_id),
    INDEX idx_status(status)
) ENGINE=InnoDB COMMENT '排课';

DROP TABLE IF EXISTS attendance;
CREATE TABLE attendance (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    schedule_id         BIGINT          NOT NULL UNIQUE COMMENT '一个排课最多一条打卡',
    teacher_id          BIGINT          NOT NULL,
    campus_id           BIGINT          NOT NULL,
    actual_start_time   DATETIME        DEFAULT NULL COMMENT '实际开始时间(教师点打卡开始)',
    actual_end_time     DATETIME        DEFAULT NULL COMMENT '实际结束时间',
    duration_minutes    INT             DEFAULT NULL COMMENT '实际时长(分钟)',
    student_count       INT             DEFAULT 0 COMMENT '实到人数',
    leave_count         INT             DEFAULT 0 COMMENT '请假人数(不算人头费)',
    absent_count        INT             DEFAULT 0 COMMENT '缺勤人数',
    exception_note      TEXT            DEFAULT NULL COMMENT '异常说明',
    location_fingerprint JSON           DEFAULT NULL COMMENT '{gps, ssid}',
    validation_warnings JSON            DEFAULT NULL COMMENT '系统自动校验结果',
    audit_status        TINYINT         NOT NULL DEFAULT 0 COMMENT '0待审核 1通过 2驳回',
    audit_by            BIGINT          DEFAULT NULL,
    audit_at            DATETIME        DEFAULT NULL,
    audit_remark        VARCHAR(255)    DEFAULT NULL,
    is_makeup           TINYINT         NOT NULL DEFAULT 0 COMMENT '0否 1补卡',
    schedule_adjusted   TINYINT         NOT NULL DEFAULT 0 COMMENT '排课事后是否调整过',
    schedule_cancelled  TINYINT         NOT NULL DEFAULT 0 COMMENT '排课是否已取消',
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_teacher_month(teacher_id, actual_start_time),
    INDEX idx_audit_status(audit_status)
) ENGINE=InnoDB COMMENT '打卡记录';

-- ==================== 计费规则 ====================

DROP TABLE IF EXISTS rule_template;
CREATE TABLE rule_template (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(64)     NOT NULL COMMENT '如:K12标准课时费模板',
    description         VARCHAR(255)    DEFAULT NULL,
    formula_template    TEXT            NOT NULL COMMENT '公式骨架，如:base_rate * hours + headcount_amount + course_bonus + level_bonus + time_slot_subsidy',
    param_schema        JSON            NOT NULL COMMENT '参数定义数组',
    supported_dimensions JSON           DEFAULT NULL,
    status              TINYINT         NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
    created_by          BIGINT          DEFAULT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT '计费规则模板';

DROP TABLE IF EXISTS rule_version;
CREATE TABLE rule_version (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    template_id         BIGINT          NOT NULL,
    version_no          VARCHAR(16)     NOT NULL COMMENT 'v1/v2.1',
    formula             TEXT            NOT NULL COMMENT '固化的完整公式(含参数)',
    default_params      JSON            NOT NULL COMMENT '本版本默认参数值',
    effective_from      DATE            NOT NULL COMMENT '生效开始(含)',
    effective_to        DATE            DEFAULT NULL COMMENT '生效结束(含),NULL=长期',
    status              TINYINT         NOT NULL DEFAULT 0 COMMENT '0草稿 2已发布 3已停用',
    change_log          VARCHAR(500)    NOT NULL COMMENT '变更说明',
    created_by          BIGINT          DEFAULT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_template_version(template_id, version_no),
    INDEX idx_effective(effective_from, effective_to, status)
) ENGINE=InnoDB COMMENT '规则版本';

DROP TABLE IF EXISTS teacher_rule_binding;
CREATE TABLE teacher_rule_binding (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    teacher_id          BIGINT          NOT NULL,
    rule_version_id     BIGINT          NOT NULL,
    effective_from      DATE            NOT NULL,
    effective_to        DATE            DEFAULT NULL,
    param_overrides     JSON            DEFAULT NULL COMMENT '教师个性化覆盖参数,null表示用版本默认值',
    priority            INT             NOT NULL DEFAULT 100 COMMENT '同时段多绑定时取高优先级',
    created_by          BIGINT          DEFAULT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_teacher_version_start(teacher_id, rule_version_id, effective_from),
    INDEX idx_teacher_date(teacher_id, effective_from, effective_to)
) ENGINE=InnoDB COMMENT '教师规则绑定';

-- ==================== 工资计算 ====================

DROP TABLE IF EXISTS salary_snapshot;
CREATE TABLE salary_snapshot (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    teacher_id          BIGINT          NOT NULL,
    attendance_id       BIGINT          NOT NULL,
    rule_version_id     BIGINT          NOT NULL,
    snapshot_month      VARCHAR(7)      NOT NULL COMMENT '如:2026-11',
    snapshot_time       DATETIME        NOT NULL,
    formula_snapshot    TEXT            NOT NULL,
    params_snapshot     JSON            NOT NULL,
    attendance_snapshot JSON            NOT NULL,
    teacher_info_snapshot JSON          NOT NULL,
    schedule_info_snapshot JSON         NOT NULL,
    calculation_trace   JSON            NOT NULL COMMENT '分步计算轨迹',
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_teacher_month(teacher_id, snapshot_month),
    INDEX idx_attendance(attendance_id)
) ENGINE=InnoDB COMMENT '工资计算快照';

DROP TABLE IF EXISTS salary_detail;
CREATE TABLE salary_detail (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    statement_id        BIGINT          DEFAULT NULL COMMENT '聚合到工资单后回填',
    teacher_id          BIGINT          NOT NULL,
    attendance_id       BIGINT          NOT NULL,
    schedule_id         BIGINT          NOT NULL,
    calc_month          VARCHAR(7)      NOT NULL,
    hours               DECIMAL(5,2)    NOT NULL COMMENT '课时数=时长分钟/60',
    base_amount         DECIMAL(12,2)   NOT NULL DEFAULT 0,
    headcount_amount    DECIMAL(12,2)   NOT NULL DEFAULT 0,
    course_type_bonus   DECIMAL(12,2)   NOT NULL DEFAULT 0,
    level_bonus         DECIMAL(12,2)   NOT NULL DEFAULT 0,
    time_slot_subsidy   DECIMAL(12,2)   NOT NULL DEFAULT 0,
    detail_amount       DECIMAL(12,2)   NOT NULL DEFAULT 0,
    rule_version_id     BIGINT          NOT NULL,
    snapshot_id         BIGINT          NOT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_statement(statement_id),
    INDEX idx_teacher_month(teacher_id, calc_month),
    INDEX idx_attendance(attendance_id)
) ENGINE=InnoDB COMMENT '工资明细';

DROP TABLE IF EXISTS salary_statement;
CREATE TABLE salary_statement (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    teacher_id          BIGINT          NOT NULL,
    campus_id           BIGINT          NOT NULL,
    month               VARCHAR(7)      NOT NULL COMMENT '工资月份 2026-11',
    gross_amount        DECIMAL(12,2)   NOT NULL DEFAULT 0 COMMENT '应发合计',
    adjustment_amount   DECIMAL(12,2)   NOT NULL DEFAULT 0 COMMENT '调整项合计',
    net_amount          DECIMAL(12,2)   NOT NULL DEFAULT 0 COMMENT '实发合计=应发+调整',
    status              TINYINT         NOT NULL DEFAULT 0 COMMENT '0草稿 1已确认 2已锁定 3已发放',
    locked_at           DATETIME        DEFAULT NULL,
    locked_by           BIGINT          DEFAULT NULL,
    paid_at             DATETIME        DEFAULT NULL,
    paid_voucher        VARCHAR(64)     DEFAULT NULL,
    remark              VARCHAR(255)    DEFAULT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_teacher_month(teacher_id, month),
    INDEX idx_campus_month(campus_id, month),
    INDEX idx_status(status)
) ENGINE=InnoDB COMMENT '工资单';

DROP TABLE IF EXISTS adjustment_item;
CREATE TABLE adjustment_item (
    id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    statement_id        BIGINT          NOT NULL,
    teacher_id          BIGINT          NOT NULL,
    month               VARCHAR(7)      NOT NULL,
    adjust_type         VARCHAR(16)     NOT NULL COMMENT '补发/扣款/奖金/其他',
    amount              DECIMAL(12,2)   NOT NULL COMMENT '正=增加 负=减少',
    reason              TEXT            NOT NULL,
    related_attendance_id BIGINT       DEFAULT NULL,
    status              TINYINT         NOT NULL DEFAULT 0 COMMENT '0草稿 1已确认',
    apply_by            BIGINT          DEFAULT NULL,
    apply_at            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_statement(statement_id),
    INDEX idx_teacher_month(teacher_id, month)
) ENGINE=InnoDB COMMENT '工资调整项';

-- ==================== 用户与审计 ====================

DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id              BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(32)     NOT NULL UNIQUE,
    password        VARCHAR(128)    NOT NULL COMMENT 'BCrypt加密',
    name            VARCHAR(32)     NOT NULL,
    role            VARCHAR(32)     NOT NULL COMMENT 'TEACHER/CAMPUS_ADMIN/JIAOWU/FINANCE/SALARY_ADMIN/SUPER_ADMIN',
    campus_id       BIGINT          DEFAULT NULL COMMENT '数据隔离：校区管理员关联本校区',
    teacher_id      BIGINT          DEFAULT NULL COMMENT '教师角色关联 teacher.id',
    status          TINYINT         NOT NULL DEFAULT 1,
    last_login_at   DATETIME        DEFAULT NULL,
    last_login_ip   VARCHAR(45)     DEFAULT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_role(role),
    INDEX idx_campus(campus_id)
) ENGINE=InnoDB COMMENT '后台系统用户';

DROP TABLE IF EXISTS audit_log;
CREATE TABLE audit_log (
    id              BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    operator_id     BIGINT          NOT NULL,
    operator_name   VARCHAR(32)     DEFAULT NULL,
    action          VARCHAR(32)     NOT NULL COMMENT 'CREATE/UPDATE/DELETE/PUBLISH/LOCK/EXPORT/CALC',
    target_type     VARCHAR(32)     NOT NULL,
    target_id       BIGINT          DEFAULT NULL,
    target_name     VARCHAR(255)    DEFAULT NULL,
    before_value    JSON            DEFAULT NULL,
    after_value     JSON            DEFAULT NULL,
    remark          VARCHAR(255)    DEFAULT NULL,
    client_ip       VARCHAR(45)     DEFAULT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_operator(operator_id),
    INDEX idx_target(target_type, target_id),
    INDEX idx_time(created_at)
) ENGINE=InnoDB COMMENT '审计日志';

SET FOREIGN_KEY_CHECKS = 1;
