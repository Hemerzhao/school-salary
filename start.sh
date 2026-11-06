#!/bin/bash
# ============================================================
# 一键启动脚本：初始化数据库 → 启动后端 → 启动前端
# 适用于 Mac / Linux，要求本机已安装: mysql, java 21, mvn, node
# ============================================================

set -e
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "🚀  教师工资统计系统启动脚本"
echo "📁 项目根目录: $ROOT_DIR"

# ---------- Step 1: 数据库初始化 ----------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/4: 数据库初始化"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-root}"

if command -v mysql &> /dev/null; then
    mysql -u "$DB_USER" -p"$DB_PASS" < "$ROOT_DIR/sql/01_init_schema.sql"
    mysql -u "$DB_USER" -p"$DB_PASS" < "$ROOT_DIR/sql/02_seed_data.sql"
    echo "✅ 数据库初始化完成"
else
    echo "⚠️  未找到 mysql 命令，请手动执行 sql/01_init_schema.sql 和 sql/02_seed_data.sql"
fi

# ---------- Step 2: 编译后端 ----------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/4: 编译后端 (Spring Boot)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$ROOT_DIR/backend"
if command -v mvn &> /dev/null; then
    mvn clean package -DskipTests
    echo "✅ 后端编译完成"
else
    echo "⚠️  未找到 mvn，请先安装 Maven 3.9+"
    exit 1
fi

# ---------- Step 3: 启动后端 ----------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/4: 启动后端服务 (http://localhost:8080/api)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

java -jar target/salary-backend-1.0.0.jar &
BACKEND_PID=$!
echo "✅ 后端 PID=$BACKEND_PID"

# 等后端起来
sleep 8
if kill -0 $BACKEND_PID 2>/dev/null; then
    echo "✅ 后端已启动"
else
    echo "❌ 后端启动失败，请检查日志"
    exit 1
fi

# ---------- Step 4: 启动前端 ----------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/4: 启动管理后台前端 (http://localhost:5173)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$ROOT_DIR/admin-web"
if command -v npm &> /dev/null; then
    npm install
    npm run dev &
    echo "✅ 管理后台已启动，请浏览器打开 http://localhost:5173"
else
    echo "⚠️  未找到 npm，跳过前端启动。请手动 cd admin-web && npm install && npm run dev"
fi

# ---------- 完成 ----------
echo ""
echo "🎉  全部启动完成！"
echo ""
echo "=== 后端 API ==="
echo "http://localhost:8080/api"
echo ""
echo "=== 管理后台 ==="
echo "http://localhost:5173"
echo ""
echo "=== 初始账号 (密码都是 admin123) ==="
echo "  super    - 超管"
echo "  salary   - 计费管理员"
echo "  finance  - 财务"
echo "  jiaowu   - 教务"
echo "  campus1  - 朝阳校区管理员"
echo "  teacher1 - 张老师（教师端）"
echo "  teacher2 - 李老师（教师端）"
echo "  teacher3 - 王老师（教师端）"
echo ""
echo "=== 教师端小程序 ==="
echo "请用 Taro 4 / 微信开发者工具打开 teacher-miniapp 目录"
echo "npm install && npm run dev:weapp"
echo ""
echo "按 Ctrl+C 退出所有服务"

wait
