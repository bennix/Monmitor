# Monitor

一个用于 macOS 的自动截屏监控应用程序，使用 SwiftUI 开发。

## 功能特点

- 🖥️ **自动截屏监控**：定时自动截取屏幕内容
- ⌨️ **全局快捷键**：支持 ⌘⇧M 快捷键快速呼出界面（可自定义）
- 🔒 **后台运行**：关闭窗口后程序继续在后台运行
- 📁 **文件管理**：截屏文件自动保存到用户目录的 Screenshots 文件夹
- 🎛️ **简洁界面**：现代化的 macOS 原生界面设计
- 🚀 **开机启动**：支持开机自动启动功能

## 系统要求

- macOS 10.15 或更高版本
- Xcode 12.0 或更高版本（用于编译）

## 安装与运行

1. 克隆此仓库到本地
2. 使用 Xcode 打开 `Monitor.xcodeproj`
3. 编译并运行项目

## 使用说明

### 首次启动
- 应用程序启动后会显示欢迎界面
- 程序会自动开始截屏监控
- 截屏文件保存在 `/Users/<UserName>/Library/Containers/com.englishrepeat.Monitor/Data/Screenshots` 文件夹中

### 快捷键操作
- **⌘⇧M**：显示/隐藏主界面（默认快捷键，可在设置中修改）

### 后台运行
- 点击窗口关闭按钮后，程序会切换到后台运行模式
- 使用全局快捷键可以重新呼出界面
- 程序会发送系统通知提醒用户快捷键操作

## 技术架构

- **开发语言**：Swift
- **UI 框架**：SwiftUI
- **系统集成**：AppKit（用于窗口管理和系统交互）
- **架构模式**：MVVM

## 主要组件

- `MonitorApp.swift`：应用程序入口和生命周期管理
- `ContentView.swift`：主界面视图
- `AppDelegate.swift`：系统事件处理和窗口管理


## 许可证

此项目仅供学习和个人使用。

## 注意事项

- 首次运行时可能需要授予屏幕录制权限
- 建议在系统偏好设置中允许应用程序的辅助功能权限以获得最佳体验
- 截屏文件会占用存储空间，请定期清理不需要的文件

---

如有问题或建议，欢迎提交 Issue 或 Pull Request。 
