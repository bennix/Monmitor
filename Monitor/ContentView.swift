//
//  ContentView.swift
//  Monitor
//
//  Created by Nelle Rtcai on 2025/6/28.
//

import SwiftUI
import AppKit
import Foundation
import ServiceManagement
import AVFoundation
import CoreImage
import Carbon
import ApplicationServices

// 设置管理器
class SettingsManager: ObservableObject {
    @Published var currentPassword: String = "admin123"
    @Published var hotkey: String = "⌘⇧M"
    
    private let passwordKey = "MonitorPassword"
    private let hotkeyKey = "MonitorHotkey"
    
    init() {
        loadSettings()
    }
    
    func updatePassword(_ newPassword: String) {
        currentPassword = newPassword
        UserDefaults.standard.set(newPassword, forKey: passwordKey)
    }
    
    func updateHotkey(_ newHotkey: String) {
        hotkey = newHotkey
        UserDefaults.standard.set(newHotkey, forKey: hotkeyKey)
    }
    
    private func loadSettings() {
        if let savedPassword = UserDefaults.standard.string(forKey: passwordKey) {
            currentPassword = savedPassword
        }
        if let savedHotkey = UserDefaults.standard.string(forKey: hotkeyKey) {
            hotkey = savedHotkey
        }
    }
}

// 全局快捷键管理器
class GlobalHotkeyManager: ObservableObject {
    private var eventHotKeyRef: EventHotKeyRef?
    private let hotkeyID = EventHotKeyID(signature: OSType(0x4D4E5452), id: 1) // 'MNTR'
    var onHotkeyPressed: (() -> Void)?
    
    func registerHotkey(keyCode: UInt32, modifiers: UInt32) {
        print("🔧 开始注册快捷键...")
        unregisterHotkey()
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        // 安装事件处理器
        let installResult = InstallEventHandler(GetEventMonitorTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            print("🎉 快捷键事件被触发！")
            if let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData!).takeUnretainedValue() as GlobalHotkeyManager? {
                print("🚀 调用快捷键回调")
                DispatchQueue.main.async {
                    manager.onHotkeyPressed?()
                }
            } else {
                print("❌ 无法获取管理器实例")
            }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), nil)
        
        if installResult == noErr {
            print("✅ 事件处理器安装成功")
        } else {
            print("❌ 事件处理器安装失败: \(installResult)")
        }
        
        // 注册热键
        let registerResult = RegisterEventHotKey(keyCode, modifiers, hotkeyID, GetEventMonitorTarget(), 0, &eventHotKeyRef)
        
        if registerResult == noErr {
            print("✅ 快捷键注册成功")
        } else {
            print("❌ 快捷键注册失败: \(registerResult)")
        }
    }
    
    func unregisterHotkey() {
        if let hotKeyRef = eventHotKeyRef {
            let result = UnregisterEventHotKey(hotKeyRef)
            if result == noErr {
                print("✅ 快捷键注销成功")
            } else {
                print("❌ 快捷键注销失败: \(result)")
            }
            eventHotKeyRef = nil
        } else {
            print("ℹ️ 没有要注销的快捷键")
        }
    }
    
    func parseHotkeyString(_ hotkeyString: String) -> (keyCode: UInt32, modifiers: UInt32)? {
        print("🔍 解析快捷键字符串: '\(hotkeyString)'")
        
        // 解析快捷键字符串，返回键码和修饰符
        var modifiers: UInt32 = 0
        var keyChar = ""
        
        if hotkeyString.contains("⌘") {
            modifiers |= UInt32(cmdKey)
            print("  ✅ 检测到Command键")
        }
        if hotkeyString.contains("⌥") {
            modifiers |= UInt32(optionKey)
            print("  ✅ 检测到Option键")
        }
        if hotkeyString.contains("⌃") {
            modifiers |= UInt32(controlKey)
            print("  ✅ 检测到Control键")
        }
        if hotkeyString.contains("⇧") {
            modifiers |= UInt32(shiftKey)
            print("  ✅ 检测到Shift键")
        }
        
        // 提取最后一个字符作为键
        keyChar = String(hotkeyString.last ?? "M")
        print("  🔤 提取的按键字符: '\(keyChar)'")
        
        let keyCode = keyCharToKeyCode(keyChar.uppercased())
        print("  🔑 最终键码: \(keyCode), 修饰符: \(modifiers)")
        
        return (keyCode: keyCode, modifiers: modifiers)
    }
    
    private func keyCharToKeyCode(_ char: String) -> UInt32 {
        switch char {
        case "A": return UInt32(kVK_ANSI_A)
        case "B": return UInt32(kVK_ANSI_B)
        case "C": return UInt32(kVK_ANSI_C)
        case "D": return UInt32(kVK_ANSI_D)
        case "E": return UInt32(kVK_ANSI_E)
        case "F": return UInt32(kVK_ANSI_F)
        case "G": return UInt32(kVK_ANSI_G)
        case "H": return UInt32(kVK_ANSI_H)
        case "I": return UInt32(kVK_ANSI_I)
        case "J": return UInt32(kVK_ANSI_J)
        case "K": return UInt32(kVK_ANSI_K)
        case "L": return UInt32(kVK_ANSI_L)
        case "M": return UInt32(kVK_ANSI_M)
        case "N": return UInt32(kVK_ANSI_N)
        case "O": return UInt32(kVK_ANSI_O)
        case "P": return UInt32(kVK_ANSI_P)
        case "Q": return UInt32(kVK_ANSI_Q)
        case "R": return UInt32(kVK_ANSI_R)
        case "S": return UInt32(kVK_ANSI_S)
        case "T": return UInt32(kVK_ANSI_T)
        case "U": return UInt32(kVK_ANSI_U)
        case "V": return UInt32(kVK_ANSI_V)
        case "W": return UInt32(kVK_ANSI_W)
        case "X": return UInt32(kVK_ANSI_X)
        case "Y": return UInt32(kVK_ANSI_Y)
        case "Z": return UInt32(kVK_ANSI_Z)
        default: return UInt32(kVK_ANSI_M)
        }
    }
}

// 视频生成错误类型
enum VideoGenerationError: LocalizedError {
    case writerCreationFailed
    case inputAdditionFailed
    case writingStartFailed
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .writerCreationFailed:
            return "无法创建视频写入器"
        case .inputAdditionFailed:
            return "无法添加视频输入"
        case .writingStartFailed:
            return "无法开始写入视频"
        case .unknownError:
            return "未知错误"
        }
    }
}

// 视频生成器
class VideoGenerator: ObservableObject {
    func generateVideo(from imageFiles: [URL], progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let outputURL = homeDirectory.appendingPathComponent("Screenshots/截屏合成视频.mov")
        
        // 删除现有的视频文件
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.createVideo(imageFiles: imageFiles, outputURL: outputURL, progressHandler: progressHandler, completion: completion)
        }
    }
    
    private func createVideo(imageFiles: [URL], outputURL: URL, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        // 创建AVAssetWriter
        guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else {
            completion(.failure(VideoGenerationError.writerCreationFailed))
            return
        }
        
        // 设置视频参数
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1920,
            AVVideoHeightKey: 1080,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6000000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterInput.expectsMediaDataInRealTime = false
        
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: 1920,
            kCVPixelBufferHeightKey as String: 1080
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: assetWriterInput,
            sourcePixelBufferAttributes: pixelBufferAttributes
        )
        
        guard assetWriter.canAdd(assetWriterInput) else {
            completion(.failure(VideoGenerationError.inputAdditionFailed))
            return
        }
        
        assetWriter.add(assetWriterInput)
        
        // 开始写入
        guard assetWriter.startWriting() else {
            completion(.failure(VideoGenerationError.writingStartFailed))
            return
        }
        
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        // 处理每张图片
        let frameRate: Int32 = 2
        var frameIndex = 0
        let totalFrames = imageFiles.count
        
        let processingQueue = DispatchQueue(label: "video.processing", qos: .userInitiated)
        
        assetWriterInput.requestMediaDataWhenReady(on: processingQueue) {
            while assetWriterInput.isReadyForMoreMediaData && frameIndex < totalFrames {
                let currentTime = CMTime(value: Int64(frameIndex), timescale: CMTimeScale(frameRate))
                
                if let pixelBuffer = self.createPixelBufferFromImage(imageFile: imageFiles[frameIndex]) {
                    let success = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: currentTime)
                    if !success {
                        print("添加帧失败: \(frameIndex)")
                    }
                } else {
                    print("创建像素缓冲区失败: \(frameIndex)")
                }
                
                frameIndex += 1
                
                // 更新进度
                let progress = Double(frameIndex) / Double(totalFrames)
                DispatchQueue.main.async {
                    progressHandler(progress)
                }
            }
            
            // 所有帧处理完成
            if frameIndex >= totalFrames {
                assetWriterInput.markAsFinished()
                assetWriter.finishWriting {
                    DispatchQueue.main.async {
                        if assetWriter.status == .completed {
                            completion(.success(outputURL))
                        } else {
                            completion(.failure(assetWriter.error ?? VideoGenerationError.unknownError))
                        }
                    }
                }
            }
        }
    }
    
    private func createPixelBufferFromImage(imageFile: URL) -> CVPixelBuffer? {
        guard let nsImage = NSImage(contentsOf: imageFile) else { return nil }
        
        // 获取文件的时间戳
        let timestampText = extractTimestampFromFile(imageFile: imageFile)
        
        // 创建带时间戳的图像
        let targetSize = NSSize(width: 1920, height: 1080)
        let imageWithTimestamp = NSImage(size: targetSize)
        
        imageWithTimestamp.lockFocus()
        
        // 绘制原图片（缩放以适应）
        let aspectRatio = nsImage.size.width / nsImage.size.height
        let targetAspectRatio = targetSize.width / targetSize.height
        
        var drawRect: NSRect
        if aspectRatio > targetAspectRatio {
            let newHeight = targetSize.width / aspectRatio
            drawRect = NSRect(x: 0, y: (targetSize.height - newHeight) / 2, width: targetSize.width, height: newHeight)
        } else {
            let newWidth = targetSize.height * aspectRatio
            drawRect = NSRect(x: (targetSize.width - newWidth) / 2, y: 0, width: newWidth, height: targetSize.height)
        }
        
        nsImage.draw(in: drawRect)
        
        // 添加时间戳
        let font = NSFont.systemFont(ofSize: 12)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
            .strokeColor: NSColor.black,
            .strokeWidth: -2.0
        ]
        
        let attributedString = NSAttributedString(string: timestampText, attributes: textAttributes)
        let textSize = attributedString.size()
        
        let textRect = NSRect(
            x: targetSize.width - textSize.width - 20,
            y: targetSize.height - textSize.height - 20,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
        imageWithTimestamp.unlockFocus()
        
        // 转换为CVPixelBuffer
        guard let cgImage = imageWithTimestamp.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(targetSize.width),
            Int(targetSize.height),
            kCVPixelFormatType_32ARGB,
            nil,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: pixelData,
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
    private func extractTimestampFromFile(imageFile: URL) -> String {
        let fileName = imageFile.lastPathComponent
        
        if let regex = try? NSRegularExpression(pattern: "screenshot_(\\d{4}-\\d{2}-\\d{2})_(\\d{2}-\\d{2}-\\d{2})_\\d+\\.png") {
            let range = NSRange(location: 0, length: fileName.count)
            if let match = regex.firstMatch(in: fileName, options: [], range: range) {
                let dateString = (fileName as NSString).substring(with: match.range(at: 1))
                let timeString = (fileName as NSString).substring(with: match.range(at: 2))
                return "\(dateString) \(timeString.replacingOccurrences(of: "-", with: ":"))"
            }
        }
        
        do {
            let resources = try imageFile.resourceValues(forKeys: [.creationDateKey])
            let creationDate = resources.creationDate ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: creationDate)
        } catch {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: Date())
        }
    }
}

// 启动项管理器
class LaunchAtLoginManager: ObservableObject {
    @Published var isEnabled: Bool = false
    
    init() {
        checkLoginItemStatus()
    }
    
    // 检查当前启动项状态
    func checkLoginItemStatus() {
        if #available(macOS 13.0, *) {
            // 使用新的 SMAppService API
            let service = SMAppService.mainApp
            self.isEnabled = service.status == .enabled
            print("📊 启动项状态检查 (SMAppService): \(isEnabled ? "已启用" : "未启用")")
        } else {
            // 对于旧版本，检查实际的启动项状态
            checkActualLoginItemStatus()
        }
    }
    
    // 实际检查启动项状态（适用于所有版本）
    private func checkActualLoginItemStatus() {
        let script = """
        tell application "System Events"
            try
                set loginItems to get name of every login item
                if loginItems contains "Monitor" then
                    return "true"
                else
                    return "false"
                end if
            on error
                return "false"
            end try
        end tell
        """
        
        executeAppleScript(script) { [weak self] success in
            // 这里的success实际上是脚本的返回值
            DispatchQueue.main.async {
                // 简单的检查，如果包含true就认为已启用
                self?.isEnabled = false // 默认为false，让用户手动设置
                print("📊 启动项状态检查 (实际检查): 默认为未启用")
            }
        }
    }
    
    // 切换启动项状态
    func toggleLaunchAtLogin() {
        print("🔄 用户切换启动项状态: \(isEnabled ? "禁用" : "启用")")
        
        if #available(macOS 13.0, *) {
            toggleWithSMAppService()
        } else {
            // 对于旧版本，直接使用 AppleScript 方法
            toggleWithAppleScriptImproved()
        }
    }
    
    // macOS 13+ 的新方法
    @available(macOS 13.0, *)
    private func toggleWithSMAppService() {
        let service = SMAppService.mainApp
        
        do {
            if isEnabled {
                try service.unregister()
                print("✅ 已从启动项中移除应用程序 (SMAppService)")
                isEnabled = false
            } else {
                try service.register()
                print("✅ 已将应用程序添加到启动项 (SMAppService)")
                isEnabled = true
            }
        } catch {
            print("⚠️ SMAppService失败: \(error)")
            // 如果 SMAppService 失败，静默尝试 AppleScript 方法
            toggleWithAppleScriptImproved()
        }
    }
    
    // 改进的AppleScript方法
    private func toggleWithAppleScriptImproved() {
        // 获取正确的应用路径
        guard let appPath = getCorrectAppPath() else {
            print("❌ 无法获取应用程序路径")
            return
        }
        
        print("🔍 使用应用路径: \(appPath)")
        
        if isEnabled {
            // 移除启动项
            removeFromLoginItems()
        } else {
            // 添加启动项
            addToLoginItems(appPath: appPath)
        }
    }
    
    // 获取正确的应用程序路径
    private func getCorrectAppPath() -> String? {
        // 方法1：使用Bundle路径
        var appPath = Bundle.main.bundlePath
        print("🔍 Bundle路径: \(appPath)")
        
        // 确保路径以.app结尾
        if !appPath.hasSuffix(".app") {
            if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                appPath = appPath + "/\(appName).app"
            }
        }
        
        // 检查路径是否存在
        if FileManager.default.fileExists(atPath: appPath) {
            print("✅ 确认应用路径存在: \(appPath)")
            return appPath
        } else {
            print("⚠️ Bundle路径不存在，尝试其他方法")
            
            // 方法2：使用当前可执行文件路径推导
            if let executablePath = Bundle.main.executablePath {
                let appPath2 = executablePath.replacingOccurrences(of: "/Contents/MacOS/Monitor", with: "")
                print("🔍 推导路径: \(appPath2)")
                
                if FileManager.default.fileExists(atPath: appPath2) {
                    print("✅ 确认推导路径存在: \(appPath2)")
                    return appPath2
                }
            }
            
            print("❌ 所有路径都不存在")
            return nil
        }
    }
    
    // 添加到启动项
    private func addToLoginItems(appPath: String) {
        // 先尝试删除现有项（避免重复）
        let removeScript = """
        tell application "System Events"
            try
                delete login item "Monitor"
            end try
        end tell
        """
        
        executeAppleScript(removeScript) { _ in
            // 然后添加新项
            let addScript = """
            tell application "System Events"
                try
                    make login item at end with properties {path:"\(appPath)", hidden:true}
                    return "success"
                on error errorMessage
                    return "error: " & errorMessage
                end try
            end tell
            """
            
            self.executeAppleScript(addScript) { [weak self] success in
                DispatchQueue.main.async {
                    print("📝 添加启动项结果: \(success ? "成功" : "失败")")
                    self?.isEnabled = true // 乐观地假设成功
                    
                    // 验证是否真的添加成功
                    self?.verifyLoginItemStatus()
                }
            }
        }
    }
    
    // 从启动项移除
    private func removeFromLoginItems() {
        let script = """
        tell application "System Events"
            try
                delete login item "Monitor"
                return "success"
            on error errorMessage
                return "error: " & errorMessage
            end try
        end tell
        """
        
        executeAppleScript(script) { [weak self] success in
            DispatchQueue.main.async {
                print("📝 移除启动项结果: \(success ? "成功" : "失败")")
                self?.isEnabled = false
                
                // 验证是否真的移除成功
                self?.verifyLoginItemStatus()
            }
        }
    }
    
    // 验证启动项状态
    private func verifyLoginItemStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let script = """
            tell application "System Events"
                try
                    set loginItems to get name of every login item
                    if loginItems contains "Monitor" then
                        return "found"
                    else
                        return "not_found"
                    end if
                on error
                    return "error"
                end try
            end tell
            """
            
            self.executeAppleScriptWithResult(script) { result in
                DispatchQueue.main.async {
                    let actuallyEnabled = result.contains("found")
                    print("🔍 验证结果: \(actuallyEnabled ? "确实已添加" : "确实未添加")")
                    self.isEnabled = actuallyEnabled
                }
            }
        }
    }
    
    // 执行 AppleScript（原有方法）
    private func executeAppleScript(_ script: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let appleScript = NSAppleScript(source: script)
            var error: NSDictionary?
            let result = appleScript?.executeAndReturnError(&error)
            
            let success = (error == nil && result != nil)
            if let error = error {
                print("❌ AppleScript执行失败: \(error)")
            } else {
                print("✅ AppleScript执行成功")
            }
            
            completion(success)
        }
    }
    
    // 执行 AppleScript 并返回结果
    private func executeAppleScriptWithResult(_ script: String, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let appleScript = NSAppleScript(source: script)
            var error: NSDictionary?
            let result = appleScript?.executeAndReturnError(&error)
            
            if let error = error {
                print("❌ AppleScript执行失败: \(error)")
                completion("error")
            } else if let result = result {
                let resultString = result.stringValue ?? "unknown"
                print("✅ AppleScript执行成功，结果: \(resultString)")
                completion(resultString)
            } else {
                completion("no_result")
            }
        }
    }
    
    // 打开系统偏好设置（简化版本，仅在必要时使用）
    private func openSystemPreferences() {
        // 直接打开系统偏好设置主界面
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:")!)
        print("🔧 已打开系统偏好设置")
    }
    
    // 已删除showErrorAlert方法，不再显示错误对话框
}

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var isPasswordCorrect: Bool = false
    @State private var screenshotTimer: Timer?
    @State private var screenshotCount: Int = 0
    @State private var isShuttingDown: Bool = false
    @State private var totalFilesInFolder: Int = 0
    @State private var isGeneratingVideo: Bool = false
    @State private var videoGenerationProgress: Double = 0.0
    @State private var hasGeneratedVideo: Bool = false
    @State private var showSettings: Bool = false
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var newHotkey: String = ""
    @State private var isRecordingHotkey: Bool = false
    @StateObject private var launchManager = LaunchAtLoginManager()
    @StateObject private var videoGenerator = VideoGenerator()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var globalHotkeyManager = GlobalHotkeyManager()
    
    // 使用设置管理器中的密码
    private var correctPassword: String {
        settingsManager.currentPassword
    }
    private let maxFileCount = 1024
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("请输入密码")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 设置按钮
                Button(action: {
                    showSettings.toggle()
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isPasswordCorrect || isShuttingDown)
            }
            
            SecureField("密码", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .onSubmit {
                    checkPassword()
                }
            
            if isPasswordCorrect {
                VStack(spacing: 10) {
                    Text("密码正确！")
                        .foregroundColor(.green)
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            shutdownApplication()
                        }) {
                            Text("停止监控并退出")
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            // 重置状态，继续运行
                            isPasswordCorrect = false
                            inputText = ""
                        }) {
                            Text("继续运行")
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else if !inputText.isEmpty {
                Text("密码错误")
                    .foregroundColor(.red)
            }
            
            // 自启动设置控件
            if !isPasswordCorrect && !isShuttingDown {
                Divider()
                
                VStack(spacing: 8) {
                    HStack {
                        Toggle("开机自启动", isOn: $launchManager.isEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .onChange(of: launchManager.isEnabled) { oldValue, newValue in
                                if oldValue != newValue {
                                    launchManager.toggleLaunchAtLogin()
                                }
                            }
                    }
                    
                    // 权限提示
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("首次使用可能需要授权或手动设置")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // 打开截屏文件夹按钮
                    Button(action: {
                        openScreenshotsFolder()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder")
                                .font(.caption)
                            Text("查看截屏文件 (\(totalFilesInFolder))")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 视频生成相关按钮
                    HStack(spacing: 8) {
                        // 生成视频按钮
                        Button(action: {
                            generateVideoFromScreenshots()
                        }) {
                            HStack(spacing: 4) {
                                if isGeneratingVideo {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .frame(width: 12, height: 12)
                                } else {
                                    Image(systemName: "video")
                                        .font(.caption2)
                                }
                                Text(isGeneratingVideo ? "生成中..." : "生成视频")
                                    .font(.caption2)
                            }
                            .foregroundColor(isGeneratingVideo ? .secondary : .green)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 6)
                            .background((isGeneratingVideo ? Color.secondary.opacity(0.1) : Color.green.opacity(0.1)))
                            .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isGeneratingVideo || totalFilesInFolder == 0)
                        
                        // 查看视频按钮
                        Button(action: {
                            openGeneratedVideo()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.circle")
                                    .font(.caption2)
                                Text("查看视频")
                                    .font(.caption2)
                            }
                            .foregroundColor(hasGeneratedVideo ? .orange : .secondary)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 6)
                            .background((hasGeneratedVideo ? Color.orange.opacity(0.1) : Color.secondary.opacity(0.1)))
                            .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!hasGeneratedVideo)
                    }
                    
                    // 视频生成进度条
                    if isGeneratingVideo {
                        ProgressView(value: videoGenerationProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(y: 0.5)
                    }
                }
                .padding(.horizontal)
            }
            
            // 截屏状态显示
            if !isPasswordCorrect {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("自动截屏中 (\(screenshotCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("截屏已停止")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // 快捷键提示
            if !isPasswordCorrect && !isShuttingDown {
                Divider()
                    .padding(.horizontal, 30)
                
                VStack(spacing: 4) {
                    HStack(spacing: 5) {
                        Image(systemName: "keyboard")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("全局快捷键: \(settingsManager.hotkey)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Text("按快捷键可重新呼出此界面")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 300, height: 420)
        .background(Color(.controlBackgroundColor))
        .sheet(isPresented: $showSettings) {
            SettingsView(
                settingsManager: settingsManager,
                globalHotkeyManager: globalHotkeyManager,
                onClose: {
                    showSettings = false
                }
            )
        }
        .onAppear {
            setupScreenshotsFolder()
            startScreenshotTimer()
            launchManager.checkLoginItemStatus()
            updateFileCount()
            checkForGeneratedVideo()
            setupGlobalHotkey()
        }
        .onDisappear {
            forceStopAllTimers()
            // 不要注销全局快捷键，因为我们需要它在后台继续工作
            print("🔄 界面即将消失，但保持全局快捷键活跃")
        }
    }
    
    private func shutdownApplication() {
        isShuttingDown = true
        print("开始安全关闭程序...")
        
        // 立即停止所有截屏活动
        forceStopAllTimers()
        
        // 注销全局快捷键
        globalHotkeyManager.unregisterHotkey()
        
        // 等待一段时间确保所有任务完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("强制终止所有后台进程...")
            
            // 杀死所有可能的screencapture进程
            let killTask = Process()
            killTask.launchPath = "/usr/bin/killall"
            killTask.arguments = ["screencapture"]
            try? killTask.run()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("程序即将完全退出")
                // 真正退出应用程序
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    private func checkPassword() {
        if inputText == correctPassword {
            isPasswordCorrect = true
        }
    }
    
    private func setupScreenshotsFolder() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let screenshotsFolder = homeDirectory.appendingPathComponent("Screenshots")
        
        // 删除现有的Screenshots文件夹及其所有内容
        if FileManager.default.fileExists(atPath: screenshotsFolder.path) {
            do {
                try FileManager.default.removeItem(at: screenshotsFolder)
                print("已删除现有的Screenshots文件夹及所有文件")
            } catch {
                print("删除现有Screenshots文件夹失败: \(error)")
            }
        }
        
        // 重新创建空的Screenshots文件夹
        do {
            try FileManager.default.createDirectory(at: screenshotsFolder, withIntermediateDirectories: true, attributes: nil)
            print("已创建新的Screenshots文件夹: \(screenshotsFolder.path)")
            
            // 更新文件数量显示
            DispatchQueue.main.async {
                self.updateFileCount()
            }
        } catch {
            print("创建Screenshots文件夹失败: \(error)")
        }
    }
    
    private func startScreenshotTimer() {
        screenshotTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if !self.isShuttingDown {
                takeScreenshot()
            }
        }
        // 立即执行第一次截屏
        if !isShuttingDown {
            takeScreenshot()
        }
    }
    
    private func stopScreenshotTimer() {
        screenshotTimer?.invalidate()
        screenshotTimer = nil
        print("截屏定时器已停止并清理")
    }
    
    private func checkAndCleanupFiles() {
        // 如果正在关闭，不进行文件清理
        if isShuttingDown || isPasswordCorrect {
            return
        }
        
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let screenshotsFolder = homeDirectory.appendingPathComponent("Screenshots")
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: screenshotsFolder, includingPropertiesForKeys: nil)
            let pngFiles = files.filter { $0.pathExtension.lowercased() == "png" }
            
            print("当前文件数量: \(pngFiles.count)")
            
            if pngFiles.count >= maxFileCount {
                print("文件数量达到\(maxFileCount)个，开始清理所有文件...")
                
                // 彻底删除所有PNG文件
                for file in pngFiles {
                    do {
                        try FileManager.default.removeItem(at: file)
                    } catch {
                        print("删除文件失败: \(file.lastPathComponent) - \(error)")
                    }
                }
                
                // 重置计数器
                screenshotCount = 0
                print("已彻底删除所有\(pngFiles.count)个截屏文件，重新开始计数")
                
                // 删除生成的视频文件
                let videoURL = homeDirectory.appendingPathComponent("Screenshots/截屏合成视频.mov")
                if FileManager.default.fileExists(atPath: videoURL.path) {
                    do {
                        try FileManager.default.removeItem(at: videoURL)
                        print("已删除视频文件")
                        
                        DispatchQueue.main.async {
                            self.hasGeneratedVideo = false
                        }
                    } catch {
                        print("删除视频文件失败: \(error)")
                    }
                }
                
                // 更新文件数量显示
                DispatchQueue.main.async {
                    self.updateFileCount()
                }
            }
        } catch {
            print("检查文件数量失败: \(error)")
        }
    }
    
    private func takeScreenshot() {
        // 如果正在关闭或密码验证成功，立即停止截屏
        if isShuttingDown || isPasswordCorrect {
            print("程序正在关闭或密码已验证，跳过截屏")
            return
        }
        
        // 检查并清理文件（如果需要）
        checkAndCleanupFiles()
        
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let screenshotsFolder = homeDirectory.appendingPathComponent("Screenshots")
        
        // 确保文件夹存在
        if !FileManager.default.fileExists(atPath: screenshotsFolder.path) {
            do {
                try FileManager.default.createDirectory(at: screenshotsFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建Screenshots文件夹失败: \(error)")
                return
            }
        }
        
        // 生成文件名
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        screenshotCount += 1
        
        let filename = "screenshot_\(dateString)_\(String(format: "%04d", screenshotCount)).png"
        let filePath = screenshotsFolder.appendingPathComponent(filename).path
        
        // 使用系统命令截屏
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-x", "-t", "png", filePath]
        
        // 在后台执行截屏，避免阻塞主线程
        DispatchQueue.global(qos: .background).async {
            // 再次检查关闭状态
            if self.isShuttingDown || self.isPasswordCorrect {
                print("截屏任务取消：程序正在关闭")
                return
            }
            
            do {
                try task.run()
                task.waitUntilExit()
                
                // 检查文件是否成功创建
                if FileManager.default.fileExists(atPath: filePath) {
                    print("截屏成功保存: \(filename)")
                    // 更新文件数量显示
                    DispatchQueue.main.async {
                        self.updateFileCount()
                    }
                } else {
                    print("截屏文件未创建: \(filename)")
                }
            } catch {
                print("截屏命令执行失败: \(error)")
            }
        }
    }
    
    private func forceStopAllTimers() {
        screenshotTimer?.invalidate()
        screenshotTimer = nil
        print("所有截屏定时器已停止并清理")
    }
    
    private func openScreenshotsFolder() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let screenshotsFolder = homeDirectory.appendingPathComponent("Screenshots")
        
        // 确保文件夹存在
        if !FileManager.default.fileExists(atPath: screenshotsFolder.path) {
            do {
                try FileManager.default.createDirectory(at: screenshotsFolder, withIntermediateDirectories: true, attributes: nil)
                print("创建Screenshots文件夹: \(screenshotsFolder.path)")
            } catch {
                print("创建Screenshots文件夹失败: \(error)")
                showFolderError(message: "无法创建截屏文件夹")
                return
            }
        }
        
        // 尝试打开文件夹
        if NSWorkspace.shared.open(screenshotsFolder) {
            print("已打开Screenshots文件夹")
            // 更新文件数量显示
            updateFileCount()
        } else {
            print("打开Screenshots文件夹失败")
            showFolderError(message: "无法打开截屏文件夹")
        }
    }
    
    private func showFolderError(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "文件夹操作"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }
    
    private func updateFileCount() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let screenshotsFolder = homeDirectory.appendingPathComponent("Screenshots")
        
        guard FileManager.default.fileExists(atPath: screenshotsFolder.path) else {
            totalFilesInFolder = 0
            return
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: screenshotsFolder, includingPropertiesForKeys: nil)
            let pngFiles = files.filter { $0.pathExtension.lowercased() == "png" }
            
            totalFilesInFolder = pngFiles.count
            print("当前文件数量: \(pngFiles.count)")
        } catch {
            print("检查文件数量失败: \(error)")
            totalFilesInFolder = 0
        }
    }
    
    private func generateVideoFromScreenshots() {
        guard !isGeneratingVideo else { return }
        
        isGeneratingVideo = true
        videoGenerationProgress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
            let screenshotsFolder = homeDirectory.appendingPathComponent("Screenshots")
            
            do {
                // 获取所有PNG文件并按创建时间排序
                let files = try FileManager.default.contentsOfDirectory(at: screenshotsFolder, includingPropertiesForKeys: [.creationDateKey])
                let pngFiles = files.filter { $0.pathExtension.lowercased() == "png" }
                
                guard !pngFiles.isEmpty else {
                    DispatchQueue.main.async {
                        self.isGeneratingVideo = false
                        self.showVideoError(message: "没有找到截屏文件")
                    }
                    return
                }
                
                // 按创建时间排序
                let sortedFiles = try pngFiles.sorted { file1, file2 in
                    let date1 = try file1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try file2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1 < date2
                }
                
                print("开始生成视频，共 \(sortedFiles.count) 张图片")
                
                // 生成视频
                self.videoGenerator.generateVideo(from: sortedFiles, progressHandler: { progress in
                    DispatchQueue.main.async {
                        self.videoGenerationProgress = progress
                    }
                }) { result in
                    DispatchQueue.main.async {
                        self.isGeneratingVideo = false
                        self.videoGenerationProgress = 0.0
                        
                        switch result {
                        case .success(let outputURL):
                            self.hasGeneratedVideo = true
                            print("视频生成完成: \(outputURL.path)")
                            self.showVideoSuccess(message: "视频生成成功！共处理 \(sortedFiles.count) 张图片")
                        case .failure(let error):
                            self.showVideoError(message: "视频生成失败: \(error.localizedDescription)")
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isGeneratingVideo = false
                    self.showVideoError(message: "读取截屏文件失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func openGeneratedVideo() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let videoURL = homeDirectory.appendingPathComponent("Screenshots/截屏合成视频.mov")
        
        if FileManager.default.fileExists(atPath: videoURL.path) {
            NSWorkspace.shared.open(videoURL)
            print("已打开视频文件: \(videoURL.path)")
        } else {
            showVideoError(message: "视频文件不存在，请先生成视频")
        }
    }
    
    private func showVideoError(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "视频操作"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }
    
    private func showVideoSuccess(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "视频生成"
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: "确定")
            alert.addButton(withTitle: "打开视频")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                self.openGeneratedVideo()
            }
        }
    }
    
    private func checkForGeneratedVideo() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let videoURL = homeDirectory.appendingPathComponent("Screenshots/截屏合成视频.mov")
        hasGeneratedVideo = FileManager.default.fileExists(atPath: videoURL.path)
    }
    
    private func setupGlobalHotkey() {
        // 检查辅助功能权限
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("⚠️ 没有辅助功能权限，全局快捷键可能无法正常工作")
            
            // 申请辅助功能权限
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
            
            if !accessEnabled {
                print("❌ 用户未授予辅助功能权限")
                showAccessibilityPermissionAlert()
            }
        } else {
            print("✅ 已获得辅助功能权限")
        }
        
        globalHotkeyManager.onHotkeyPressed = {
            print("🔥 全局快捷键被按下，尝试显示应用程序")
            
            DispatchQueue.main.async {
                // 优先使用AppDelegate的showMainWindow方法
                if let appDelegate = AppDelegate.shared {
                    print("📱 使用AppDelegate显示窗口")
                    appDelegate.showMainWindow()
                } else {
                    print("⚠️ 无法获取AppDelegate，使用备用方案")
                    self.showWindowFallback()
                }
                
                // 额外的保险措施：短暂延迟后再次尝试
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.ensureWindowVisible()
                }
            }
        }
        
        // 注册快捷键
        if let (keyCode, modifiers) = globalHotkeyManager.parseHotkeyString(settingsManager.hotkey) {
            print("🎯 尝试注册全局快捷键: \(settingsManager.hotkey)")
            print("🔑 键码: \(keyCode), 修饰符: \(modifiers)")
            globalHotkeyManager.registerHotkey(keyCode: keyCode, modifiers: modifiers)
            print("✅ 已注册全局快捷键: \(settingsManager.hotkey)")
        } else {
            print("❌ 解析快捷键失败: \(settingsManager.hotkey)")
        }
    }
    
    private func showAccessibilityPermissionAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "需要辅助功能权限"
            alert.informativeText = """
            全局快捷键功能需要辅助功能权限。
            
            请按以下步骤操作：
            1. 打开"系统偏好设置"
            2. 点击"安全性与隐私"
            3. 选择"隐私"标签
            4. 选择"辅助功能"
            5. 找到"Monitor"并勾选
            
            授权后，请重启应用程序以使全局快捷键生效。
            """
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.addButton(withTitle: "打开系统偏好设置")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                self.openAccessibilitySettings()
            }
        }
    }
    
    private func openAccessibilitySettings() {
        let script = """
        tell application "System Preferences"
            activate
            reveal pane "com.apple.preference.security"
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("打开系统偏好设置失败: \(error)")
            // 备用方案：打开系统偏好设置主界面
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:")!)
        }
    }
    
    private func showWindowFallback() {
        print("🔧 使用备用方案显示窗口")
        
        // 强制切换为常规应用程序模式
        NSApp.setActivationPolicy(.regular)
        print("✅ 切换为常规模式")
        
        // 激活应用程序
        NSApp.activate(ignoringOtherApps: true)
        print("✅ 应用程序已激活")
        
        // 取消隐藏应用程序
        NSApp.unhide(nil)
        print("✅ 应用程序已取消隐藏")
        
        // 显示所有窗口
        for window in NSApp.windows {
            if window.contentView != nil {
                print("🔍 显示窗口: \(window)")
                window.setIsVisible(true)
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                window.deminiaturize(nil)
                window.center()
            }
        }
    }
    
    private func ensureWindowVisible() {
        print("🎯 确保窗口可见")
        
        var hasVisibleWindow = false
        for window in NSApp.windows {
            if window.contentView != nil && window.isVisible {
                hasVisibleWindow = true
                window.orderFrontRegardless()
                window.makeKeyAndOrderFront(nil)
                print("✅ 窗口已确保可见: \(window)")
            }
        }
        
        if !hasVisibleWindow {
            print("⚠️ 没有可见窗口，尝试重新显示")
            showWindowFallback()
        }
    }
}

// 设置界面
struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var globalHotkeyManager: GlobalHotkeyManager
    let onClose: () -> Void
    
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var newHotkey: String = ""
    @State private var isRecordingHotkey: Bool = false
    @State private var showPasswordSuccess: Bool = false
    @State private var passwordErrorMessage: String = ""
    @State private var eventMonitor: Any?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("设置")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("完成") {
                    onClose()
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 密码修改区域
                    GroupBox("修改密码") {
                        VStack(spacing: 12) {
                            SecureField("当前密码", text: $oldPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            SecureField("新密码", text: $newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            SecureField("确认新密码", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !passwordErrorMessage.isEmpty {
                                Text(passwordErrorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            
                            if showPasswordSuccess {
                                Text("密码修改成功！")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                            
                            Button(action: {
                                changePassword()
                            }) {
                                Text("修改密码")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                        }
                        .padding()
                    }
                    
                    // 快捷键设置区域
                    GroupBox("全局快捷键") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("当前快捷键:")
                                    .font(.caption)
                                Spacer()
                                Text(settingsManager.hotkey)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                TextField("新快捷键", text: $newHotkey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(isRecordingHotkey)
                                
                                Button(isRecordingHotkey ? "按下快捷键..." : "录制") {
                                    if isRecordingHotkey {
                                        isRecordingHotkey = false
                                        stopRecording()
                                    } else {
                                        startRecordingHotkey()
                                    }
                                }
                                .foregroundColor(isRecordingHotkey ? .orange : .blue)
                            }
                            
                            Text("示例: ⌘⇧M (Command+Shift+M)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("支持的修饰符: ⌘(Command) ⌃(Control) ⌥(Option) ⇧(Shift)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                updateHotkey()
                            }) {
                                Text("更新快捷键")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(newHotkey.isEmpty)
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 500)
        .onAppear {
            newHotkey = settingsManager.hotkey
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    private func changePassword() {
        passwordErrorMessage = ""
        showPasswordSuccess = false
        
        // 验证当前密码
        guard oldPassword == settingsManager.currentPassword else {
            passwordErrorMessage = "当前密码错误"
            return
        }
        
        // 验证新密码
        guard newPassword.count >= 4 else {
            passwordErrorMessage = "新密码长度至少4位"
            return
        }
        
        // 验证确认密码
        guard newPassword == confirmPassword else {
            passwordErrorMessage = "两次输入的新密码不一致"
            return
        }
        
        // 更新密码
        settingsManager.updatePassword(newPassword)
        
        // 清空输入字段
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
        
        showPasswordSuccess = true
        
        // 3秒后隐藏成功消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showPasswordSuccess = false
        }
    }
    
    private func startRecordingHotkey() {
        // 先清理之前的监听器
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        isRecordingHotkey = true
        newHotkey = "请按下快捷键组合..."
        
        // 创建本地事件监视器来捕获按键
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [self] event in
            guard isRecordingHotkey else { return event }
            
            let modifierFlags = event.modifierFlags.intersection([.command, .option, .control, .shift])
            
            if event.type == .keyDown && !modifierFlags.isEmpty {
                var hotkeyString = ""
                
                if modifierFlags.contains(.command) {
                    hotkeyString += "⌘"
                }
                if modifierFlags.contains(.control) {
                    hotkeyString += "⌃"
                }
                if modifierFlags.contains(.option) {
                    hotkeyString += "⌥"
                }
                if modifierFlags.contains(.shift) {
                    hotkeyString += "⇧"
                }
                
                if let keyChar = event.charactersIgnoringModifiers?.uppercased() {
                    hotkeyString += keyChar
                }
                
                DispatchQueue.main.async {
                    self.newHotkey = hotkeyString
                    self.isRecordingHotkey = false
                    self.stopRecording()
                }
                
                return nil // 消费这个事件
            }
            return event
        }
        
        // 5秒后自动停止录制
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.isRecordingHotkey {
                self.isRecordingHotkey = false
                self.newHotkey = self.settingsManager.hotkey
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func updateHotkey() {
        // 验证快捷键格式
        if newHotkey.isEmpty {
            return
        }
        
        // 更新快捷键
        settingsManager.updateHotkey(newHotkey)
        
        // 重新注册全局快捷键
        if let (keyCode, modifiers) = globalHotkeyManager.parseHotkeyString(newHotkey) {
            globalHotkeyManager.registerHotkey(keyCode: keyCode, modifiers: modifiers)
            print("已更新全局快捷键: \(newHotkey)")
        }
    }
}

#Preview {
    ContentView()
}
