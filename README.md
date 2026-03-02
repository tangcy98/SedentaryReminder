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

### 终端命令行编译

如果你不想打开 Xcode UI，可以用终端命令编译：

**第一步：安装 Command Line Tools**
```bash
xcode-select --install
```
弹出提示时选择"安装"，等待下载完成。

**第二步：克隆并编译项目**
```bash
# 克隆项目
git clone https://github.com/tangcy98/SedentaryReminder.git
cd SedentaryReminder

# 编译项目（会自动签名）
xcodebuild -project SedentaryReminder.xcodeproj -scheme SedentaryReminder -configuration Debug build

# 编译成功后，应用在这里：
# ~/Library/Developer/Xcode/DerivedData/SedentaryReminder-xxx/Build/Products/Debug/SedentaryReminder.app
```

**第三步：运行应用**
```bash
# 方式1：直接打开
open ~/Library/Developer/Xcode/DerivedData/SedentaryReminder-*/Build/Products/Debug/SedentaryReminder.app

# 方式2：复制到应用程序目录
cp -r ~/Library/Developer/Xcode/DerivedData/SedentaryReminder-*/Build/Products/Debug/SedentaryReminder.app /Applications/
```

**第四步：设置开机启动**
```bash
# 启用开机自启
defaults write com.apple.loginwindow AutoLaunchedApplicationDictionary -array-add -dict path="/Applications/SedentaryReminder.app"
```

**查看编译状态**
```bash
# 查看最后生成的 app 路径
ls -la ~/Library/Developer/Xcode/DerivedData/SedentaryReminder-*/Build/Products/Debug/*.app
```

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
