#!/bin/bash
# 查看当前公网访问地址（cloudflared quick tunnel 重启后地址会变化）

ADMIN=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' /tmp/cf-admin.log 2>/dev/null | tail -1)
TEACHER=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' /tmp/cf-teacher.log 2>/dev/null | tail -1)
LAN=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)

echo "=========================================="
echo "  公网地址（任何人可访问）"
echo "=========================================="
if [ -n "$ADMIN" ]; then
  echo "  管理端: $ADMIN"
else
  echo "  管理端: 未启动"
fi
if [ -n "$TEACHER" ]; then
  echo "  教师端: $TEACHER"
else
  echo "  教师端: 未启动"
fi
echo ""
echo "=========================================="
echo "  局域网地址（同一 Wi-Fi 下可访问）"
echo "=========================================="
echo "  管理端: http://$LAN:5173"
echo "  教师端: http://$LAN:5174"
echo ""
echo "隧道服务状态："
launchctl list | grep salary | awk '{print "  " $3 "  (PID " $1 ")"}'
