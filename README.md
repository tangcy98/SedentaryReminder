# SedentaryReminder

macOS 菜单栏久坐提醒应用 - 定时提醒你起来活动身体

## 功能特性

- 📌 **菜单栏常驻** - 简洁的菜单栏图标设计
- ⏰ **可调提醒间隔** - 30分钟、45分钟、1小时、90分钟、2小时
- 🏃 **8种健身动作** - 颈部环绕、肩部耸动、背部伸展、站立拉伸、眼球放松、手腕活动、腰椎放松、深呼吸
- 🔀 **播放模式** - 支持随机或顺序播放
- 🔔 **声音提醒** - 可开关的提示音
- 🚀 **开机自启** - 支持登录时自动启动

## 技术栈

- SwiftUI + AppKit
- UserNotifications
- SMAppService (macOS 13+)

## 使用方法

### 编译运行

1. 克隆项目到本地
   ```bash
   git clone https://github.com/tangcy98/SedentaryReminder.git
   cd SedentaryReminder
   ```

2. 用 Xcode 打开项目
   ```bash
   open SedentaryReminder.xcodeproj
   ```
   或者直接打开文件夹后双击 `.xcodeproj` 文件

3. 编译运行
   - 按 `Cmd + R` 或点击 Xcode 右上角的运行按钮
   - 首次运行会提示签名配置，选择 "Sign to Run Locally" 即可

4. 使用应用
   - 应用启动后会在 macOS 菜单栏显示图标（一个行走的小人）
   - 点击图标可弹出设置面板
   - 点击菜单栏空白区域可关闭设置面板

### 设置开机启动

**方法一：应用内设置**
- 打开设置面板，底部显示 "✓ 登录时自动启动"
- 表示已自动启用开机自启（仅支持 macOS 13+）

**方法二：系统设置**
1. 打开系统设置 → 通用 → 登录项
2. 点击 "登录时打开" 按钮
3. 添加 `SedentaryReminder` 应用

**方法三：终端命令**
```bash
# 启用开机自启
 defaults write com.apple.loginwindow AutoLaunchedApplicationDictionary -array-add -dict path="/Applications/SedentaryReminder.app"
```

## 注意事项

- 需要授予通知权限才能接收提醒
- 首次运行需要允许应用访问通知
- 开机自启功能仅支持 macOS 13 (Ventura) 及以上版本
