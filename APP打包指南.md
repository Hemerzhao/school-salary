# App 打包指南

本文档说明如何把 **teacher-app（教师端）** 和 **admin-app（管理端）** 打包成手机 App（APK / iOS）以及微信小程序。

两个项目均为 **uni-app + Vue 3**，一套代码可输出四种形态：

| 形态 | 说明 |
|------|------|
| 安卓 APK | HBuilderX 云打包，无需自备证书（可用公共测试证书） |
| iOS IPA | HBuilderX 云打包，需要苹果开发者账号证书 |
| 微信小程序 | `npm run build:mp-weixin` 后用微信开发者工具打开 |
| H5 网页 | `npm run build:h5`，可部署到任意静态服务器 |

---

## 〇、准备工作（一次性）

1. 下载安装 **HBuilderX**（https://www.dcloud.io/hbuilderx.html），选"标准版"即可
2. 注册 **DCloud 开发者账号**（云打包需要）
3. 确保后端已部署到一台可访问的服务器（不能一直是 localhost，手机装上后要能连到）

### 上线前必改：API 地址

两个项目的 `src/utils/request.js` 中：

```js
// #ifdef APP-PLUS || MP-WEIXIN
const BASE_URL = 'http://localhost:8080/api'   // ← 改成你的服务器地址，如 https://salary.xxx.com/api
// #endif
```

> 注意：微信小程序正式版要求 HTTPS；App 打包也强烈建议 HTTPS（可用免费的 Let's Encrypt / 阿里云证书）。

---

## 一、HBuilderX 云打包 APK（推荐路径）

### 步骤

1. HBuilderX 菜单：**文件 → 导入 → 从本地目录导入**，选择 `teacher-app` 或 `admin-app` 目录
2. 先本地验证一次：工具栏 **运行 → 运行到浏览器 → Chrome**，确认页面正常（后端启动状态下可真实联调）
3. 菜单：**发行 → 原生 App-云打包**
4. 弹窗中配置：
   - **Android 包名**：如 `com.school.salaryteacher`（teacher-app）/ `com.school.salaryadmin`（admin-app），一旦上架不要更换
   - **证书**：第一次选"**使用公共测试证书**"（快速出包；正式上架后再换成自有证书）
   - **打包类型**：正式包 / 测试包（测试即可先装到自己手机验证）
   - **渠道**：留空或选默认
5. 点击"打包"，等待 5~15 分钟，控制台会给出 APK 下载链接
6. 把 APK 发到教师/管理员手机安装即可（安卓允许"安装未知来源应用"）

### iOS 打包

- 需要 Apple 开发者账号（$99/年）
- HBuilderX 云打包时选 iOS + 上传 .p12 证书和描述文件
- 个人开发者账号打包的 IPA 需要通过 TestFlight 或 ad-hoc 分发

---

## 二、微信小程序输出

### 教师端（teacher-app）

```bash
cd teacher-app
npm install
npm run build:mp-weixin
```

产物在 `dist/build/mp-weixin/`，用微信开发者工具导入该目录：

1. 填入你已注册的小程序 AppID（改 `src/manifest.json` 里 `mp-weixin.appid`）
2. 小程序后台 → 开发管理 → 服务器域名，把后端域名加入 **request 合法域名**（必须 HTTPS）
3. 开发者工具点"上传"，再到 mp.weixin.qq.com 提交审核发布

### 管理端（admin-app）

同样流程。管理端如果要给固定几个人用，也可以不发布、用"体验版"二维码，扫码即可使用（体验版有效期较长，内部使用够用）。

---

## 三、H5 形态（可选，快速给管理员用）

```bash
cd admin-app
npm run build:h5
# 产物 dist/build/h5，丢到 Nginx 静态目录即可
```

手机浏览器 / 微信内置浏览器打开，也可以"添加到主屏幕"当 PWA 用。这是最快让管理员用起来的方式，不用等打包审核。

---

## 四、tabBar 图标

- **admin-app**：`src/static/tabbar/` 已内置 8 张占位图标，开箱可跑；正式图标直接覆盖同名文件
- **teacher-app**：`src/static/tabbar/` 目前为空，需放置 8 张 81×81 png：

```
home.png  home-active.png          # 首页
calendar.png calendar-active.png   # 课表
money.png  money-active.png       # 工资
user.png   user-active.png         # 我的
```

图标免费来源：iconfont.cn 搜索"首页/日历/钱包/用户"下载 png。

---

## 五、App 权限说明（已配置在 manifest.json）

| 项目 | 权限 | 用途 |
|------|------|------|
| teacher-app | ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION | 打卡定位（GPS 校验是否在校区范围） |
| teacher-app | INTERNET | 访问后端 API |
| admin-app | INTERNET | 访问后端 API（无定位需求） |

---

## 六、项目对应关系总览

```
temp_20261106_03/
├── backend/           Spring Boot 后端（唯一数据源，所有端共用）
├── sql/               数据库脚本
├── admin-web/         管理后台桌面版（Vue3 + Element Plus，浏览器用）
├── admin-app/         管理端手机 App（uni-app，可出 APK/小程序/H5）★ 新增
├── teacher-miniapp/   教师端 Taro 小程序（早期版本，保留）
└── teacher-app/       教师端手机 App（uni-app，可出 APK/小程序/H5）★ 新增，推荐用这个
```

> `teacher-miniapp`（Taro 版）与 `teacher-app`（uni-app 版）功能一致；uni-app 版可同时出 App 和小程序，后续建议以 `teacher-app` 为主线，Taro 版可弃用。
