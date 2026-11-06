# 贡献指南

感谢你想为这个开源项目做贡献！以下是几个简单的规则。

## 开发环境

| 依赖 | 版本 | 推荐安装方式 |
|------|------|--------------|
| JDK | 21 | https://adoptium.net/ |
| Maven | 3.9+ | Homebrew / 官网下载 |
| Node.js | 18+ | nvm 或官网 |
| MySQL | 8.0+ | Docker / 官网 |
| Git | 任意 | - |

## 本地启动

```bash
# 一键脚本（macOS / Linux）
./start.sh

# Docker 方式（推荐，零环境依赖）
docker compose up -d

# 分步
# 1. 数据库
mysql -uroot -proot < sql/01_init_schema.sql
mysql -uroot -proot < sql/02_seed_data.sql
# 2. 后端
cd backend && mvn spring-boot:run
# 3. 前端（另开终端）
cd admin-web && npm install && npm run dev
cd teacher-app && npm install && npm run dev:h5
cd admin-app  && npm install && npm run dev:h5
```

默认账号（密码统一 `admin123`）：

| 用户名 | 角色 |
|--------|------|
| `super` | 超管 |
| `salary` | 计费管理员 |
| `finance` | 财务 |
| `jiaowu` | 教务 |
| `campus1` | 校区管理员 |
| `teacher1` / `teacher2` / `teacher3` | 教师 |

## PR 流程

1. **先开 Issue 讨论**（功能请求 / bug / 架构变更）
2. Fork 本仓库
3. 创建特性分支：`git checkout -b feat/your-feature` 或 `git checkout -b fix/your-bug`
4. 提交前自测（后端 `mvn package -DskipTests` 通过 + 前端能跑）
5. 推送分支 → 提交 PR
6. 等待 review → 合并

**不要**提交的内容：`target/`、`node_modules/`、`.env`、IDE 配置、私有密钥。

## 代码规范

- **后端**：Java 21 + Spring Boot 3 惯用风格。Entity 用 Lombok `@Data`，Service 用 `@RequiredArgsConstructor` 依赖注入，Controller 返回 `Result<T>`。JSON 字段驼峰。
- **前端**：Vue 3 `<script setup>`。admin-web 用 Element Plus；uni-app 两项目用内置组件 + scss，不引额外 UI 库。
- **数据库变更**：DDL 改动附 `sql/` 下新的版本化脚本（如 `03_xx_migration.sql`），不要直接改 `01_init_schema.sql`。
- **接口新增/变更**：更新 Swagger UI 注释（`@Operation` / `@Tag`）。

## 规则引擎相关变更

课时费规则引擎是本项目核心，改动前务必理解四层模型：

```
rule_template  →  rule_version  →  teacher_rule_binding  →  salary_snapshot
```

修改计算公式、参数 schema 或快照结构时，记得：
- `param_schema` 的字段名与后端 SalaryCalcService 读取逻辑保持一致
- 新增维度（比如"课时类型系数"）时，同步改 `calc_single_attendance` 的 trace 输出

## 开源协议

本项目采用 **MIT License**，你提交的代码也会以 MIT 协议授权给社区。
