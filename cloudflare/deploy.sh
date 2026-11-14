#!/usr/bin/env bash
# 一键部署：先备份线上数据库 → 再打包代码 → 再发布页面
#
# 重要：本脚本只部署代码（_worker.js + 静态页面），不会执行 schema.sql，
# 也不会执行任何 DROP/DELETE 语句，因此教师、班级、学生、课次、工资、管理员账号全部保留。
#
# 用法：  ./deploy.sh            # 备份 + 构建 + 部署
#        ./deploy.sh --no-backup # 跳过备份（不建议）
set -euo pipefail
cd "$(dirname "$0")"

export PATH="$HOME/opt/node/bin:$PATH"
PROJECT="school-salary-page"
PAGES_DIR="pages/public"

# 系统 DNS 偶发无法解析 Cloudflare 时，自动改用本地代理（Clash 默认 7890）
if ! curl -s --max-time 4 -o /dev/null https://dash.cloudflare.com/ 2>/dev/null; then
  if curl -s --max-time 3 -o /dev/null -x http://127.0.0.1:7890 https://dash.cloudflare.com/ 2>/dev/null; then
    export HTTPS_PROXY=http://127.0.0.1:7890 HTTP_PROXY=http://127.0.0.1:7890
    echo "ℹ️ 系统直连失败，已自动使用本地代理 127.0.0.1:7890"
  fi
fi

if [ "${1:-}" != "--no-backup" ]; then
  echo "▶ 1/3 备份线上数据库…"
  ./backup.sh
else
  echo "⚠️ 已跳过备份"
fi

echo "▶ 2/3 打包后端 _worker.js…"
./node_modules/.bin/esbuild src/index.ts \
  --bundle --format=esm --platform=browser --target=es2022 \
  --outfile=public/_worker.js

echo "▶ 3/3 同步静态页面并发布…"
mkdir -p "$PAGES_DIR"
rsync -a --delete public/ "$PAGES_DIR"/
npx wrangler pages deploy "$PAGES_DIR" --project-name "$PROJECT" --commit-dirty=true

echo "✅ 部署完成（数据未变更）"
echo "   如需回滚数据：npx wrangler d1 time-travel info school_salary"
