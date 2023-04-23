//
//  HamsterApp.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Plist
import SwiftUI
import SwiftyBeaver

@main
struct HamsterApp: App {
  var appSettings = HamsterAppSettings()
  var rimeEngine = RimeEngine()

  @State var launchScreenState = true
  @State var showError: Bool = false
  @State var err: Error?

  var body: some Scene {
    WindowGroup {
      ZStack {
        Color.clear
          .alert(isPresented: $showError) {
            Alert(title: Text("RIME初始化异常: \(err?.localizedDescription ?? "")"), dismissButton: .cancel {
              err = nil
            })
          }
        if launchScreenState {
          LaunchScreen(appSettings.isFirstLaunch)
        } else {
          ContentView()
        }
      }
      .onOpenURL { url in
        Logger.shared.log.debug("open url: \(url)")
        if url.pathExtension.lowercased() == "zip" {
          // TODO: 添加loading
          let fm = FileManager.default
          let tempPath = URL(fileURLWithPath: NSTemporaryDirectory().appending("/Rime"))

          do {
            // 先解压到临时目录
            try fm.unzipItem(at: url, to: tempPath)
            try fm.removeItem(at: url)
            let files = try fm.contentsOfDirectory(at: tempPath, includingPropertiesForKeys: nil, options: [])
            var isRime: Bool = false
            // 查找解压的文件夹里有没有名字包含schema.yaml 的文件
            for file in files {
              if file.lastPathComponent.contains("schema.yaml") {
                isRime = true
                break
              }
            }
            if !isRime {
              // TODO: 提示压缩包内没有Rime 所需文件
              // 删除临时解压文件
              try fm.removeItem(at: tempPath)
            } else {
              let rimePath = RimeEngine.appGroupUserDataDirectoryURL
              do {
                // 判断 Rime 目录是否存在
                if fm.fileExists(atPath: rimePath.path) {
                  // 删除 Rime 目录
                  try fm.removeItem(at: rimePath)
                }
                // 移动文件夹
                try fm.moveItem(at: tempPath, to: rimePath)

                appSettings.rimeNeedOverrideUserDataDirectory = true
                // TODO: 添加提示
              } catch {
                // 处理错误
                Logger.shared.log.debug("处理 ZIP 文件时发生错误：\(error)")
              }
            }
          } catch {
            // 处理错误
            Logger.shared.log.debug("处理 ZIP 文件时发生错误：\(error)")
          }
        }
      }
      .onAppear {
        DispatchQueue.global().async {
          // 检测应用是否首次加载
          if appSettings.isFirstLaunch {
            // 加载系统默认配置上下滑动符号
            appSettings.keyboardUpAndDownSlideSymbol = Plist.defaultAction

            // RIME首次启动需要将输入方案copy到AppGroup共享目录下供Keyboard使用
            do {
              try RimeEngine.initAppGroupSharedSupportDirectory(override: true)
              try RimeEngine.initAppGroupUserDataDirectory(override: true)
            } catch {
              appSettings.isFirstLaunch = true
              Logger.shared.log.error("rime init file directory error: \(error), \(error.localizedDescription)")
              showError = true
              err = error
            }
            let traits = self.rimeEngine.createTraits(
              sharedSupportDir: RimeEngine.appGroupSharedSupportDirectoryURL.path,
              userDataDir: RimeEngine.appGroupUserDataDirectoryURL.path
            )
            rimeEngine.setupRime(traits)
            rimeEngine.startRime(traits, fullCheck: true)
            if let schema = rimeEngine.getSchemas().first {
              appSettings.rimeInputSchema = schema.schemaId
            }
            rimeEngine.shutdownRime()
            appSettings.isFirstLaunch = false
            appSettings.rimeNeedOverrideUserDataDirectory = true
          } else {
            rimeEngine.setupRime(
              sharedSupportDir: RimeEngine.appGroupSharedSupportDirectoryURL.path,
              userDataDir: RimeEngine.appGroupUserDataDirectoryURL.path
            )
          }

          // 启动屏延迟
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            launchScreenState = false
          }
        }
      }
      .environmentObject(appSettings)
      .environmentObject(rimeEngine)
    }
  }
}
