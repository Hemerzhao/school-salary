# 初始化 Git 仓库并推送到 GitHub

# 在 GitHub 上先创建一个空仓库（不要勾选任何初始化选项），假设仓库名是 school-salary
# 然后在本项目根目录执行：

git init
git add .
git commit -m "feat: 教师工资统计系统完整开源发布

- 后端：Spring Boot 3.2 + MyBatis-Plus + JWT
- 管理后台：Vue3 + Element Plus
- 教师端/管理端：uni-app（一套代码出 H5/小程序/APK）
- 数据库：MySQL 8.0
- 课时费规则动态配置 + 版本化 + 历史快照
- Docker Compose 一键启动
- LICENSE: MIT"

# 替换下面的 URL 为你的 GitHub 仓库地址
git remote add origin https://github.com/YOUR-ORG/school-salary.git

# 推送（首次用 -u 建立跟踪）
git branch -M main
git push -u origin main

echo "✅ 推送完成！访问 https://github.com/YOUR-ORG/school-salary"
