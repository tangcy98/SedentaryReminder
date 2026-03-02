# Sedentary Reminder

macOS 菜单栏久坐提醒应用，提醒你适时休息并做简单的伸展运动。

## 功能特点

- ⏱️ **定时提醒** - 30/45/60/90/120 分钟多档间隔可选
- 🧘 **8 个中文锻炼动作** - 颈部环绕、肩部耸动、背部伸展、站立拉伸、眼球放松、手腕活动、腰椎放松、深呼吸
- 🔀 **两种播放模式** - 随机或顺序播放
- 💾 **设置持久化** - 记住你的偏好设置
- 🍎 **菜单栏应用** - 状态栏图标，不显示 Dock 图标

## 代码分析

```
Analyzing SedentaryReminder...                                  
No issues found! (ran in 0.7s)
```

## 构建说明

### Windows

```powershell
# 1. 安装 Flutter SDK (如果没有)
# 下载: https://docs.flutter.dev/get-started/install/windows

# 2. 启用 Windows 桌面支持
flutter config --enable-windows-desktop

# 3. 克隆仓库
git clone https://github.com/tangcy98/SedentaryReminder.git
cd SedentaryReminder

# 4. 安装依赖
flutter pub get

# 5. 运行应用
flutter run -d windows

# 6. 构建发布版本
flutter build windows
```

### macOS

```bash
# 1. 安装 Flutter SDK (如果没有)
# 下载: https://docs.flutter.dev/get-started/install/macos

# 2. 启用 macOS 桌面支持
flutter config --enable-macos-desktop

# 3. 克隆仓库
git clone https://github.com/tangcy98/SedentaryReminder.git
cd SedentaryReminder

# 4. 安装依赖
flutter pub get

# 5. 运行应用
flutter run -d macos

# 6. 构建发布版本
flutter build macos
```

## 项目结构

```
lib/
  main.dart          # 主应用代码
macos/
  Runner/            # macOS 原生配置
pubspec.yaml         # 依赖配置
```

## 依赖

- `flutter` - Flutter SDK
- `shared_preferences` - 本地存储
- `tray_manager` - 菜单栏托盘图标

## 许可证

MIT License
