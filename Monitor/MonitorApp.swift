//
//  MonitorApp.swift
//  Monitor
//
//  Created by Nelle Rtcai on 2025/6/28.
//

import SwiftUI
import AppKit

public class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate? {
        return NSApp.delegate as? AppDelegate
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ 应用程序启动完成")
        
        // 开机时直接显示界面并保持显示
        DispatchQueue.main.async {
            // 设置为常规模式，确保可以显示界面
            NSApp.setActivationPolicy(.regular)
            
            // 显示主窗口
            self.showMainWindow()
            print("🪟 开机启动显示主窗口")
            
            // 显示欢迎提示
            self.showWelcomeAlert()
        }
        
        // 为所有窗口设置关闭行为
        DispatchQueue.main.async {
            self.setupWindowCloseHandlers()
        }
        
        print("✅ 应用程序配置完成，支持全局快捷键")
    }
    
    private func setupWindowCloseHandlers() {
        // 监听窗口创建事件
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeMainNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let window = notification.object as? NSWindow {
                self.configureWindow(window)
            }
        }
        
        // 为现有窗口设置
        for window in NSApp.windows {
            configureWindow(window)
        }
    }
    
    private func configureWindow(_ window: NSWindow) {
        // 设置窗口关闭行为：关闭时隐藏而不是销毁
        window.isReleasedWhenClosed = false
        
        // 创建自定义的关闭处理
        window.standardWindowButton(.closeButton)?.target = self
        window.standardWindowButton(.closeButton)?.action = #selector(handleWindowClose(_:))
        
        print("✅ 已配置窗口关闭行为: \(window)")
    }
    
    @objc private func handleWindowClose(_ sender: Any?) {
        print("🚪 用户点击关闭按钮，隐藏窗口而不是销毁")
        
        // 隐藏所有窗口
        for window in NSApp.windows {
            window.setIsVisible(false)
            window.orderOut(nil)
        }
        
        // 切换到辅助模式，但保持应用程序在后台运行
        NSApp.setActivationPolicy(.accessory)
        print("🔄 切换到辅助模式，应用程序继续在后台运行")
        
        // 显示提示信息，告知用户如何重新呼出界面
        self.showBackgroundModeNotification()
    }
    
    private func showBackgroundModeNotification() {
        // 显示系统通知，告知用户程序在后台运行
        let notification = NSUserNotification()
        notification.title = "Monitor 在后台运行"
        notification.informativeText = "按 ⌘⇧M 可重新呼出界面"
        notification.soundName = nil
        
        NSUserNotificationCenter.default.deliver(notification)
        print("📬 已发送后台运行通知")
    }
    
    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print("🔄 应用程序被重新打开，hasVisibleWindows: \(flag)")
        
        if !flag {
            // 如果没有可见窗口，显示主窗口
            showMainWindow()
        }
        return true
    }
    
    public func showMainWindow() {
        print("🪟 准备显示主窗口")
        
        // 强制切换为常规模式
        NSApp.setActivationPolicy(.regular)
        print("✅ 已切换为常规模式")
        
        // 确保应用程序处于激活状态
        NSApp.activate(ignoringOtherApps: true)
        print("✅ 应用程序已激活")
        
        // 显示并激活所有窗口
        var hasWindow = false
        for window in NSApp.windows {
            if window.contentView != nil {
                hasWindow = true
                window.setIsVisible(true)
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                window.deminiaturize(nil)
                window.center() // 居中显示窗口
                print("✅ 显示窗口: \(window)")
            }
        }
        
        if !hasWindow {
            print("⚠️ 没有找到有效窗口，可能需要重新创建")
        }
        
        // 确保窗口在最前面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for window in NSApp.windows {
                if window.contentView != nil && window.isVisible {
                    window.orderFrontRegardless()
                    window.makeKeyAndOrderFront(nil)
                }
            }
            print("🎯 窗口已置于最前面")
        }
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        print("ℹ️ 最后一个窗口关闭，应用程序继续在后台运行")
        // 返回false，让应用程序在后台继续运行
        return false
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        print("应用程序即将终止，清理所有资源...")
        
        // 强制杀死所有可能的screencapture进程
        let killTask = Process()
        killTask.launchPath = "/usr/bin/killall"
        killTask.arguments = ["-9", "screencapture"]
        try? killTask.run()
        
        print("清理完成，应用程序安全退出")
    }
    
    public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        print("强制终止所有后台进程...")
        return .terminateNow
    }
    
    private func showWelcomeAlert() {
        // 总是显示提示信息，确保用户知道快捷键
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = NSAlert()
            alert.messageText = "Monitor 已启动"
            alert.informativeText = """
            程序已开始自动截屏监控！
            
            重要提示：
            • 全局快捷键：⌘⇧M（可在设置中修改）
            • 关闭窗口后程序继续在后台运行
            • 使用快捷键可重新呼出界面
            • 截屏文件保存在用户目录的Screenshots文件夹
            
            祝您使用愉快！
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "我知道了")
            alert.addButton(withTitle: "不再显示")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                UserDefaults.standard.set(true, forKey: "HasShownWelcomeAlert")
            }
        }
    }
}

@main
struct MonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup("Monitor") {
            ContentView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultSize(width: 300, height: 420)
        .commands {
            // 添加菜单命令以支持窗口管理
            CommandGroup(replacing: .newItem) { }
        }
    }
}
