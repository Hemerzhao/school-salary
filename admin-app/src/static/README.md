# static 目录说明

## tabbar 图标（pages.json 引用）

tabBar 四个页签分别对应以下四组 png 图标（81x81px，普通态灰色 / 选中态主色 #1677ff）：

| 页签 | 页面 | 普通态 | 选中态 |
|---|---|---|---|
| 工作台 | pages/dashboard/dashboard | `static/tabbar/home.png` | `static/tabbar/home-active.png` |
| 审核 | pages/attendance/attendance | `static/tabbar/audit.png` | `static/tabbar/audit-active.png` |
| 工资 | pages/salary/statement | `static/tabbar/money.png` | `static/tabbar/money-active.png` |
| 我的 | pages/me/me | `static/tabbar/user.png` | `static/tabbar/user-active.png` |

## 说明

- 当前目录下已放置**程序生成的纯色占位图标**（灰/蓝方块），保证工程开箱可跑；
- 正式上线请用设计好的图标**覆盖同名文件**即可，无需改 pages.json；
- 建议规格：81x81 或 96x96 px，png 透明底，文件名保持不变；
- 如临时不需要图标，可删除 pages.json 中每项的 `iconPath` / `selectedIconPath` 字段，tabBar 会退化为纯文字样式。
