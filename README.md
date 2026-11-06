# 教师工资统计系统

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Java](https://img.shields.io/badge/Java-21-blue.svg)](https://adoptium.net/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-green.svg)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)](https://dev.mysql.com/)
[![Vue](https://img.shields.io/badge/Vue-3.x-41b883.svg)](https://vuejs.org/)
[![uni--app](https://img.shields.io/badge/uni--app-Vue3-10adff.svg)](https://uniapp.dcloud.net.cn/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ed.svg?style=flat&logo=docker&logoColor=white)](https://docs.docker.com/compose/)

> 一套完整、可开源部署的教师工资统计与追溯系统。支持打卡、课时费规则动态配置、自动计算工资、审批审计全流程。

## ✨ 特性

- **多端覆盖**：教师端（网页 / 微信小程序 / 安卓 App / iOS）+ 管理端（桌面网页 / 移动网页 / App）+ 统一后端 API
- **规则零代码配置**：课时费规则由计费管理员在后台自行调整，发布新版本即生效，**不找开发发版**
- **历史工资不可追溯性影响**：规则变更后，已锁定工资完全不变（规则版本 + 计算快照双重冻结）
- **分段累加人头费**：超过基础人数后，每增 1 人加固定金额，按请假学生自动扣除人头基数
- **可审计可追溯**：每一笔工资都能看到当时用了什么规则版本、什么参数、原始打卡数据、分步计算轨迹
- **单机可跑**：Docker Compose 一键启动（MySQL + 后端 + 前端）

## 🏗️ 技术栈

| 层 | 技术 |
|----|------|
| 后端 | Java 21 + Spring Boot 3.2 + MyBatis-Plus + JWT |
| 数据库 | MySQL 8.0 |
| 桌面管理后台 | Vue 3 + Vite + Element Plus |
| 教师端 / 管理端（网页+App+小程序） | uni-app + Vue 3（一套代码出四种形态） |
| 容器化 | Docker Compose |

## 📁 目录结构

```
.
├── backend/          Spring Boot 后端（唯一数据源，所有端共用）
├── sql/              数据库初始化脚本（DDL + 种子数据）
├── admin-web/        管理后台桌面版（Vue3 + Element Plus，浏览器直接用）
├── teacher-app/      教师端（uni-app，可出 H5 / 小程序 / APK / iOS）
├── admin-app/        管理端移动版（uni-app，同上四种形态）
├── teacher-miniapp/  教师端 Taro 小程序（历史版本，保留对照）
├── LICENSE           MIT 开源协议
├── README.md         本文件
├── docker-compose.yml   Docker 一键启动
├── start.sh          本机一键启动（macOS / Linux）
└── APP打包指南.md    App / 小程序打包说明
```

## 🚀 快速开始

### 方式一：Docker Compose（推荐，零环境依赖）

```bash
git clone https://github.com/your-org/school-salary.git
cd school-salary
docker compose up -d
# 等待 ~2 分钟，访问：
#   admin-web   → http://localhost:5173   管理后台桌面版
#   teacher-web → http://localhost:5174   教师端网页（H5 形态）
#   admin-web-h5→ http://localhost:5175   管理端网页（H5 形态）
#   后端 API    → http://localhost:8080/api
#   Swagger UI  → http://localhost:8080/api/swagger-ui.html
#   健康检查    → http://localhost:8080/api/health
#   MySQL       → localhost:3306 (user=root, password=root, db=school_salary)
```

### 方式二：本机分步启动（macOS / Linux）

```bash
# 前置依赖：MySQL 8+ / Java 21+ / Maven 3.9+ / Node 18+
./start.sh
# 或手动分步：
#   1) mysql -uroot -proot < sql/01_init_schema.sql && mysql -uroot -proot < sql/02_seed_data.sql
#   2) cd backend && mvn spring-boot:run                # 后端 :8080
#   3) cd admin-web && npm install && npm run dev      # 管理后台 :5173
#   4) cd teacher-app && npm install && npm run dev:h5 # 教师端 H5 :5174
#   5) cd admin-app  && npm install && npm run dev:h5  # 管理端 H5 :5175
```

### 初始账号（密码统一 `admin123`）

| 用户名 | 角色 | 可用端 |
|--------|------|--------|
| `super` | 超管 | 全部 |
| `salary` | 计费管理员 | 规则/工资/审计 |
| `finance` | 财务 | 工资单 |
| `jiaowu` | 教务 | 打卡审核/排课 |
| `campus1` | 朝阳校区管理员 | 本校区 |
| `teacher1`~`teacher3` | 教师 | 教师端 |

## 📱 网页形态总览

所有端都能以**纯网页**运行：

| 端 | 命令 | 产物 | 部署方式 |
|----|------|------|----------|
| 管理后台桌面版 | `cd admin-web && npm run build` | `dist/` 静态资源 | Nginx / 任意静态服务器 |
| 教师端 H5 | `cd teacher-app && npm run build:h5` | `dist/build/h5/` | 同上 |
| 管理端 H5 | `cd admin-app && npm run build:h5` | `dist/build/h5/` | 同上 |

> 教师端和管理端还能一键打包成安卓 APK / iOS IPA / 微信小程序，详见 [APP打包指南.md](./APP打包指南.md)。

## 🧾 课时费规则设计（核心亮点）

```
rule_template       公式骨架 + 参数定义（不写死任何具体值）
       ↓ 发布新版本
rule_version        固化公式 + 默认参数 + 生效区间（不可直接修改）
       ↓ 教师绑定 + 个性化覆盖
teacher_rule_binding 某教师绑定某版本 + 覆盖少数参数（如 base_rate 120→150）
       ↓ 计算时自动生成
salary_snapshot     当时的公式 + 最终参数 + 原始打卡数据 + 分步计算轨迹
```

**三重保障历史工资不变**：
1. 已发布版本禁止直接修改，只能停用 + 新建
2. 每个版本有 `effective_from / effective_to` 严格控制作用区间
3. 工资计算时一次性写入 `salary_snapshot`，后续任何规则变更不影响快照

**分段累加人头费**（已实现）：
```
tiers = [{base_count: 15, extra_per_person: 5}, {base_count: 25, extra_per_person: 8}]
# 含义：≤15人不加；16-25人时每人加 5 元；≥26人时每人加 8 元
# 请假学生不算人头费，基数 = 实到 - 请假
```

## 🧪 数据模型

15 张表，涵盖校区→教师→班级→课程→排课→打卡→规则→工资单→快照→调整项→审计。完整 DDL 在 [sql/01_init_schema.sql](./sql/01_init_schema.sql)。

核心表：

| 表 | 作用 |
|----|------|
| `rule_template` | 计费规则模板（公式骨架 + 参数定义） |
| `rule_version` | 规则版本（固化 + 生效区间） |
| `teacher_rule_binding` | 教师 ↔ 规则版本 绑定 + 个性化覆盖 |
| `salary_snapshot` | 工资计算快照（历史不可追溯性影响） |
| `salary_statement` | 工资单（0草稿→1已确认→2已锁定→3已发放） |
| `audit_log` | 全量审计日志（不可删除） |

## 🛠️ 配置后端 API 地址

uni-app 项目中 `src/utils/request.js` 用条件编译适配不同端：

```js
// 桌面 H5（开发时）→ 走 vite 代理
// teacher-app / admin-app 的 vite.config.js 已配置 '/api' → 'http://localhost:8080'

// 生产环境 → 必须改成你的服务器地址
// #ifdef APP-PLUS || MP-WEIXIN
const BASE_URL = 'https://salary.yourdomain.com/api'
// #endif
```

## 🤝 贡献

欢迎 PR。建议先开 Issue 讨论方案再提交代码。

## 📄 License

[MIT](./LICENSE) — 个人和企业均可自由使用、修改、分发，保留版权声明即可。
