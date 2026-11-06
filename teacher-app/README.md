# 教师工资助手（uni-app + Vue 3）

教师端应用：今日课程打卡、课表查询、工资单查看。基于 uni-app + Vue 3（Vite），可打包为 H5 / 微信小程序 / 安卓 APK / iOS App。

后端为 Spring Boot，接口约定：

- base 地址：`http://localhost:8080/api`
- 统一响应结构：`{ code: 0, msg: "ok", data: any }`，`code=0` 成功；HTTP 401 表示未登录
- 请求头：`Authorization: Bearer <token>`

## 一、H5 本地预览

```bash
npm install
npm run dev:h5
```

浏览器打开终端输出的地址（默认 `http://localhost:5173`）。

- H5 模式下请求走 `/api`，由 `vite.config.js` 中的代理转发到 `http://localhost:8080`，请先启动后端服务。
- H5 端浏览器定位可能因非 HTTPS 被拦截，定位失败时打卡流程会继续执行。

## 二、微信小程序

```bash
npm run dev:mp-weixin
```

1. 打开「微信开发者工具」→ 导入项目
2. 目录选择 `dist/dev/mp-weixin`（发布版为 `dist/build/mp-weixin`，用 `npm run build:mp-weixin` 产出）
3. AppID 填自己的小程序 AppID，或在 `src/manifest.json` 的 `mp-weixin.appid` 中配置
4. 开发者工具中请求 `http://localhost:8080` 需勾选「详情 → 本地设置 → 不校验合法域名」
5. 上线前：在 `src/utils/request.js` 中把 App/小程序端的 `BASE_URL` 改为正式服务器地址（需 HTTPS），并在小程序后台配置 request 合法域名
6. 发布前请补齐 `src/static/tabbar/` 下的 4 组 81x81 png 图标（见 `src/static/README.md`）

## 三、HBuilderX 云打包 APK

1. 用 HBuilderX 打开本目录（文件 → 打开目录，选择 `teacher-app` 文件夹）
2. 首次使用会提示安装 uni-app 编译插件，按提示安装即可
3. 菜单「发行」→「原生 App-云打包」
4. 打包类型勾选 **Android**；证书选择 **使用公共测试证书**；其余保持默认
5. `src/manifest.json` 已配置所需权限：`ACCESS_FINE_LOCATION`、`ACCESS_COARSE_LOCATION`、`INTERNET`，以及 Geolocation 模块
6. 点击「打包」，等待云端打包完成，通过控制台给出的链接下载 APK 安装
7. iOS 同理，需自备苹果开发者证书

注意：App 端请求 `http://localhost:8080` 仅适用于连电脑调试；正式使用请修改 `src/utils/request.js` 中的 `BASE_URL` 为服务器地址。

## 目录结构

```
teacher-app
├── index.html                  # H5 入口模板
├── package.json
├── vite.config.js              # vite 配置（含 /api 代理）
├── README.md
└── src
    ├── main.js                 # 应用入口（createSSRApp）
    ├── App.vue                 # 启动检查登录态 + 全局样式
    ├── manifest.json           # uni-app 配置（App 权限 / 小程序 appid / h5 router）
    ├── pages.json              # 路由与 tabBar 配置
    ├── uni.scss                # 全局 scss 变量
    ├── store/user.js           # token / 用户信息本地存储
    ├── utils/request.js        # uni.request 统一封装（token、401 跳登录）
    ├── utils/format.js         # 时间、金额、状态格式化
    ├── services/               # 接口层（auth / schedule / attendance / salary）
    ├── static/README.md        # tabbar 图标占位说明
    └── pages
        ├── login/login.vue     # 登录
        ├── index/index.vue     # 首页：今日课程 + 开始/结束打卡
        ├── schedule/schedule.vue # 课表：本周/本月，按日期分组
        ├── salary/salary.vue   # 工资：本月卡片 + 历史月份
        ├── salary/detail.vue   # 工资单详情：汇总 + 调整项 + 明细展开
        ├── attendance/end.vue  # 结束打卡表单
        └── me/me.vue           # 个人中心 + 退出登录
```
