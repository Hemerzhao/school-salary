#!/bin/bash
# 查看当前访问地址（ngrok 免费固定域名，重启后地址不变）

PUBLIC="https://unbroken-proximity-banknote.ngrok-free.dev"
LAN=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
HOST=$(scutil --get LocalHostName 2>/dev/null)

echo "=========================================="
echo "  公网地址（固定，任何人可访问）"
echo "=========================================="
echo "  管理端: $PUBLIC/api/admin/"
echo "  教师端: $PUBLIC/api/teacher/"
echo ""
echo "=========================================="
echo "  局域网地址（同一 Wi-Fi 下可访问）"
echo "=========================================="
echo "  管理端: http://$HOST.local:5173   (或 http://$LAN:5173)"
echo "  教师端: http://$HOST.local:5174   (或 http://$LAN:5174)"
echo ""
echo "常驻服务状态："
launchctl list | grep -i salary | awk '{print "  " $3 "  (PID " $1 ")"}'
echo ""
echo "公网连通性："
curl -s -o /dev/null -w "  健康检查 %{http_code}\n" "$PUBLIC/api/health"
