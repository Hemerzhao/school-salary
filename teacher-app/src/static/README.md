# Tabbar 图标占位说明

本项目的 tabBar 需要 **4 组图标（普通 + 选中各一张）**，建议尺寸 **81x81 PNG**，放入 `src/static/tabbar/` 目录，文件名必须与下面一致：

| 文件名 | 用途 |
| --- | --- |
| `home.png` | 首页 - 普通 |
| `home-active.png` | 首页 - 选中 |
| `calendar.png` | 课表 - 普通 |
| `calendar-active.png` | 课表 - 选中 |
| `money.png` | 工资 - 普通 |
| `money-active.png` | 工资 - 选中 |
| `user.png` | 我的 - 普通 |
| `user-active.png` | 我的 - 选中 |

注意：

1. 图标缺失时，微信小程序真机预览与 App 云打包可能报错或 tabBar 显示空白，请先补齐图标再打包。
2. tabBar 的配色与文案在 `src/pages.json` 的 `tabBar` 节点中配置：未选中 `#999999`，选中 `#1677ff`。
