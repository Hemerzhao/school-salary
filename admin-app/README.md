# admin-app（工资管理端）

基于 **uni-app + Vue 3** 的管理后台移动版，支持打包为 **安卓 APK / iOS App / 微信小程序 / H5**。

对接后端：Spring Boot，`http://localhost:8080/api`，统一响应 `{ code, msg, data }`，鉴权 `Authorization: Bearer <token>`。

## 一、开发调试

```bash
npm install          # 安装依赖（node 18+）
npm run dev:h5       # H5 调试，自动代理 /api -> http://localhost:8080
npm run dev:mp-weixin # 微信小程序调试，产物在 dist/dev/mp-weixin，用微信开发者工具导入
npm run dev:app      # App 调试（真机基座）
```

> H5 模式请求走 `/api` 代理；App / 小程序模式直连 `http://localhost:8080/api`（见 `src/utils/request.js`），真机调试请改成局域网 IP。

## 二、H5 构建

```bash
npm run build:h5
# 产物：dist/build/h5，任意静态服务器（nginx / oss）托管即可
```

## 三、微信小程序构建

```bash
npm run build:mp-weixin
# 产物：dist/build/mp-weixin
```

1. 在 `src/manifest.json` 的 `mp-weixin.appid` 填入小程序 AppID；
2. 用微信开发者工具「导入项目」选择 `dist/build/mp-weixin` 目录；
3. 「上传」提交体验版 → 在小程序后台提交审核发布。
4. 小程序真机请求需在微信公众平台配置合法域名（正式 https 地址）。

## 四、HBuilderX 云打包 APK / iOS 步骤

1. 安装 [HBuilderX](https://www.dcloud.io/hbuilderx.html)（App 开发版）；
2. 文件 → 导入 → 从本地目录导入 `admin-app`；
3. 先本地生成 App 资源：`npm run build:app`（产物 `dist/build/app`）；
   - 或直接右键项目 → 发行 → 原生 App-云打包（HBuilderX 会自动编译 vue3 源码）；
4. 菜单「发行 → 原生 App-云打包」：
   - **安卓**：包名如 `com.school.salary.admin`，证书可选「DCloud老版证书 / 云端证书 / 自有证书」，勾选「打包」即可生成 APK；
   - **iOS**：需要 Apple 开发者账号与证书（.p12 + profile），按提示填入后云打包生成 ipa；
5. 打包前确认 `src/manifest.json`：
   - `name` 为「工资管理端」；
   - `app-plus.distribute.android.permissions` 已含 `INTERNET`（管理端仅需网络权限，无定位）；
   - iOS 无需额外 capability。
6. 打包完成后在 HBuilderX 控制台点击下载链接，获得 APK / ipa 安装包。

## 五、账号角色说明

| role | 含义 | 可见功能 |
|---|---|---|
| SUPER_ADMIN | 超管 | 全部（含工资单解锁） |
| SALARY_ADMIN | 计费管理员 | 全部 |
| FINANCE | 财务 | 工资计算 / 工资单 / 调整项 / 规则校验 |
| JIAOWU / CAMPUS_ADMIN | 教务 / 校区管理员 | 打卡审核 / 排课查看 |
| TEACHER | 教师 | 管理端不开放 |

## 六、目录结构

```
admin-app/
├─ index.html            # H5 入口
├─ package.json
├─ vite.config.js        # H5 /api 代理
└─ src/
   ├─ manifest.json      # App 名称 / 权限 / 小程序 appid
   ├─ pages.json         # 页面与 tabBar 配置
   ├─ main.js / App.vue  # 启动入口（token 校验）
   ├─ uni.scss           # 全局 SCSS 变量
   ├─ static/            # tabbar 图标目录（见 static/README.md）
   ├─ store/user.js      # 登录态与角色判断
   ├─ utils/request.js   # uni.request 封装
   ├─ utils/format.js    # 金额 / 时间 / 状态格式化
   └─ pages/             # 登录、工作台、打卡审核、排课、工资、审计、我的
```
