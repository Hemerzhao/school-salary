# 教师工资统计系统（Cloudflare 版）

基于 **Cloudflare Pages + Workers + D1** 的培训机构工资/排课管理系统。

## 架构

```
浏览器
  │  HTTPS
  ▼
Cloudflare Pages（静态文件 + Worker）
  ├── public/admin/index.html    管理端
  ├── public/teacher/index.html  教师端
  └── public/_worker.js          后端 API（由 src/index.ts 打包）
              │
              ▼
         Cloudflare D1（SQLite）
```

- **前端**：纯静态 HTML/JS/CSS，部署在 Cloudflare Pages，全球 CDN。
- **后端**：Pages 附带 Worker（`public/_worker.js`，由 `src/index.ts` 经 esbuild 打包），处理所有 `/api/*` 请求。
- **数据库**：Cloudflare D1（SQLite），单库远程主库 + 只读副本。
- **认证**：JWT（72 小时有效），密码 PBKDF2 存储。

## 目录结构

```
cloudflare/
├── src/index.ts              # 后端源码（Workers）
├── public/                   # 部署目录（静态页面 + 打包后的 _worker.js）
│   ├── admin/index.html      # 管理端
│   ├── teacher/index.html    # 教师端
│   └── _worker.js            # 打包产物
├── schema.sql                # 数据库建表脚本
├── seed.sql                  # 初始数据
├── migrate-*.sql             # 历次数据迁移
├── deploy.sh                 # 打包 + 部署脚本
├── backup.sh                 # D1 备份脚本
├── wrangler.toml.example     # 配置模板（复制为 wrangler.toml 并填写）
└── package.json
```

## 快速部署

1. 安装依赖：
   ```bash
   cd cloudflare
   npm install
   ```

2. 配置：复制 `wrangler.toml.example` 为 `wrangler.toml`，填写 `database_id` 与 `JWT_SECRET`。

3. 创建 D1 数据库并导入表结构：
   ```bash
   npx wrangler d1 create school_salary
   npx wrangler d1 execute school_salary --remote --file schema.sql
   npx wrangler d1 execute school_salary --remote --file seed.sql
   ```

4. 部署：
   ```bash
   ./deploy.sh
   ```

## 功能

- 账号体系：管理员 / 教师
- 班级与学生名单管理
- 排课（按周几/时段循环，课次编号 = 教师姓名拼音首字母 + D + 课次号）
- 教师打卡 + 管理员审核
- 教师分年级课时费单独设置
- 月度工资报表
- 教室动态占用状态 + 教师月度课表
