#!/usr/bin/env bash
# 一键备份线上数据库（教师、班级、学生、课次、工资、账号）
#
# 用法：  ./backup.sh
# 产物：  cloudflare/backups/school_salary-YYYYMMDD-HHMMSS.sql（保留最近 30 份）
#
# 恢复（会把备份内容写回线上库，执行前请确认备份文件时间）：
#   export PATH="$HOME/opt/node/bin:$PATH"
#   npx wrangler d1 execute school_salary --remote --file=backups/school_salary-YYYYMMDD-HHMMSS.sql
#
# 另外 Cloudflare D1 自带「时间点恢复」，30 天内可回滚到任意时刻（无需备份文件）：
#   npx wrangler d1 time-travel info school_salary
#   npx wrangler d1 time-travel restore school_salary --timestamp=2026-11-10T10:00:00Z
set -euo pipefail
cd "$(dirname "$0")"

export PATH="$HOME/opt/node/bin:$PATH"
DB="school_salary"
OUT_DIR="backups"
KEEP=30

mkdir -p "$OUT_DIR"
STAMP=$(date +%Y%m%d-%H%M%S)
FILE="$OUT_DIR/${DB}-${STAMP}.sql"

npx wrangler d1 export "$DB" --remote --output "$FILE"
SIZE=$(du -h "$FILE" | cut -f1)
echo "✅ 已备份：$(pwd)/${FILE} (${SIZE})"

# 只保留最近 N 份
ls -1t "$OUT_DIR"/${DB}-*.sql 2>/dev/null | tail -n "+$((KEEP + 1))" | while read -r old; do
  rm -f "$old"
  echo "🧹 已清理旧备份：${old}"
done
