# Sedentary Reminder

macOS 菜单栏久坐提醒应用，提醒你适时休息并做简单的伸展运动。

## 功能特点

- ⏱️ **定时提醒** - 30/45/60/90/120 分钟多档间隔可选
- 🧘 **8 个中文锻炼动作** - 颈部环绕、肩部耸动、背部伸展、站立拉伸、眼球放松、手腕活动、腰椎放松、深呼吸
- 🔀 **两种播放模式** - 随机或顺序播放
- 💾 **设置持久化** - 记住你的偏好设置
- 🍎 **菜单栏应用** - 状态栏图标，不显示 Dock 图标

## 技术栈

- Flutter 3.24.5
- macOS (使用 tray_manager 实现菜单栏)
- shared_preferences (本地存储)

## 构建

```bash
# 安装依赖
flutter pub get

# macOS 构建
flutter build macos

# 或者在 macOS 上直接运行
flutter run -d macos
```

## 项目结构

```
lib/
  main.dart          # 主应用代码
macos/
  Runner/            # macOS 原生配置
pubspec.yaml         # 依赖配置
```

## 许可证

MIT License
