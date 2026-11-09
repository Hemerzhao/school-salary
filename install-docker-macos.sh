#!/bin/bash
# ============================================================================
#  macOS Docker 安装脚本（Apple Silicon M 系列 / Intel 都支持）
#  项目：教师工资统计系统 开源配套
#  使用：直接执行   bash install-docker-macos.sh
# ============================================================================

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║       🐳 macOS Docker Desktop 一键安装脚本                  ║"
echo "║       适配 Apple Silicon(M1/M2/M3) + Intel                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ---- 1. 环境检测 ----
ARCH=$(uname -m)
MACOS_VER=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
echo "📋 环境检测："
echo "   架构:   $ARCH"
echo "   系统:   macOS $MACOS_VER"

if [ "$ARCH" = "arm64" ]; then
  DOCKER_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
  ARCH_NAME="Apple Silicon"
elif [ "$ARCH" = "x86_64" ]; then
  DOCKER_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
  ARCH_NAME="Intel"
else
  echo "❌ 不支持的架构：$ARCH"
  exit 1
fi
echo "   Docker 下载地址: $DOCKER_URL"
echo ""

# 检查 macOS 版本（Docker Desktop 要求 12+）
MACOS_MAJOR=$(echo "$MACOS_VER" | cut -d. -f1)
if [ "$MACOS_MAJOR" -lt 12 ] 2>/dev/null; then
  echo "⚠️  Docker Desktop 要求 macOS 12+，当前是 $MACOS_VER"
  echo "   建议先升级系统：系统设置 → 通用 → 软件更新"
  echo "   继续安装可能无法运行，按 Ctrl+C 取消，或按回车继续..."
  read -r _
fi

# ---- 2. 检查是否已安装 ----
if [ -d "/Applications/Docker.app" ]; then
  echo "✅ Docker Desktop 已安装"
  if [ -f /usr/local/bin/docker ] || [ -f ~/.docker/bin/docker ]; then
    DOCKER_BIN=$(which docker 2>/dev/null || echo "")
    echo "   docker CLI 位置: $DOCKER_BIN"
    docker --version 2>/dev/null || echo "   （首次运行需要手动打开 Docker.app）"
    echo ""
    echo "💡 已安装跳过，直接进入第 5 步验证服务"
    goto verify
  fi
fi

# ---- 3. 下载 Docker Desktop ----
echo "📥 第 1/4 步：下载 Docker Desktop for $ARCH_NAME"
DMG="/tmp/Docker.dmg"
if [ -f "$DMG" ] && [ "$(stat -f%z "$DMG" 2>/dev/null)" -gt 500000000 ]; then
  echo "   ✅ 已有下载缓存，跳过"
else
  echo "   正在下载（~700MB，根据网速可能要 5-20 分钟）..."
  echo "   下载地址：$DOCKER_URL"
  curl -L "$DOCKER_URL" -o "$DMG" --progress-bar
  echo "   ✅ 下载完成，大小：$(du -h "$DMG" | cut -f1)"
fi

# ---- 4. 挂载并安装 ----
echo ""
echo "📦 第 2/4 步：挂载 DMG 并复制到 Applications"

MOUNT_POINT=$(hdiutil attach "$DMG" -nobrowse -readonly 2>&1 | grep "Apple_HFS" | awk '{print substr($0, index($0,$3))}')
if [ -z "$MOUNT_POINT" ]; then
  echo "❌ 挂载失败，手动挂载：双击 $DMG，然后把 Docker.app 拖进 Applications"
  exit 1
fi
echo "   挂载点：$MOUNT_POINT"

cp -R "$MOUNT_POINT/Docker.app" /Applications/
hdiutil detach "$MOUNT_POINT" -quiet
echo "   ✅ Docker.app 已复制到 /Applications"

# 清理 DMG
rm -f "$DMG"
echo "   ✅ 已清理下载文件"

# ---- 5. 启动 Docker Desktop ----
echo ""
echo "🚀 第 3/4 步：启动 Docker Desktop（首次打开会要求系统授权）"
open /Applications/Docker.app
echo "   已请求启动 Docker Desktop"
echo "   ⏳ 等待 Docker 引擎就绪（通常 30-90 秒）..."

# 轮询等待 Docker daemon 就绪
for i in $(seq 1 60); do
  if docker info > /dev/null 2>&1; then
    break
  fi
  sleep 2
done

# ---- 6. 验证安装 ----
verify:
echo ""
echo "🔍 第 4/4 步：验证安装"

echo "=== docker version ==="
docker --version 2>&1 || echo "❌ docker CLI 不可用，可能需要重新打开 Docker Desktop"

echo ""
echo "=== docker compose version ==="
docker compose version 2>&1 || echo "❌ docker compose 不可用"

echo ""
echo "=== 运行 hello-world 测试 ==="
docker run --rm hello-world 2>&1 | head -15 || echo "❌ 测试失败"

echo ""
echo "=== Docker Desktop 状态 ==="
if [ -d "/Applications/Docker.app" ]; then
  echo "✅ Docker Desktop: 已安装"
fi
if docker info > /dev/null 2>&1; then
  DOCKER_ROOT=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || echo "Docker Engine")
  MEM_LIMIT=$(docker info --format 'MemTotal={{.MemTotal}}' 2>/dev/null || echo "")
  echo "✅ Docker Engine: 运行中"
  echo "   架构: $ARCH_NAME"
else
  echo "❌ Docker Engine 未运行，请手动打开 /Applications/Docker.app"
fi

# ---- 7. 项目相关：拉起学校工资系统 ----
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Docker 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "👉 下一步：拉起教师工资统计系统"
echo ""
echo "   cd ~/Documents/Trae-CN/temp_20261106_03"
echo "   docker compose up -d"
echo ""
echo "   完成后访问："
echo "   管理后台 http://localhost:5173"
echo "   教师端   http://localhost:5174"
echo "   管理端   http://localhost:5175"
echo "   Swagger  http://localhost:8080/api/swagger-ui.html"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
