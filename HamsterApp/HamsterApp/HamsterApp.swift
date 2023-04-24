//
//  HamsterApp.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Plist
import SwiftUI
import SwiftyBeaver
import ZIPFoundation

@main
@available(iOS 14, *)
struct HamsterApp: App {
  var appSettings = HamsterAppSettings()
  var rimeEngine = RimeEngine()

  @State var launchScreenState = true
  @State var showError: Bool = false
  @State var err: Error?
  @State var loadingMessage: String = ""

  // Zip文件解析异常
  struct ZipParsingError: Error {
    let message: String
  }

  var body: some Scene {
    WindowGroup {
      ZStack {
        Color.clear
          .alert(isPresented: $showError) {
            Alert(
              title: Text("\(err?.localizedDescription ?? "")"),
              dismissButton: .cancel {
                err = nil
                // 异常初始化后跳转主界面
                launchScreenState = false
              }
            )
          }
        if launchScreenState {
          LaunchScreen(appSettings.isFirstLaunch, loadingMessage: $loadingMessage)
        } else {
          ContentView()
        }
      }
      .onOpenURL { url in
        Logger.shared.log.debug("open url: \(url)")

        if url.pathExtension.lowercased() == "zip" {
          // Loading: 开启加载页面
          launchScreenState = true
          loadingMessage = "Zip文件解析中..."

          let fm = FileManager()
          let tempPath = fm.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
          do {
            if fm.fileExists(atPath: tempPath.path) {
              try fm.removeItem(at: tempPath)
            }

            try fm.copyItem(atPath: url.path, toPath: tempPath.path)

            // 读取ZIP内容
            guard let archive = Archive(url: tempPath, accessMode: .read) else {
              showError = true
              err = ZipParsingError(message: "读取Zip文件异常")
              return
            }

            // 查找解压的文件夹里有没有名字包含schema.yaml 的文件
            guard let _ = archive.filter({ $0.path.contains("schema.yaml") }).first else {
              showError = true
              err = ZipParsingError(message: "Zip文件未包含输入方案文件")
              return
            }

            // 解压, 解压前先删除旧文件
            try fm.removeItem(at: RimeEngine.appGroupUserDataDirectoryURL)
            try fm.unzipItem(at: tempPath, to: RimeEngine.appGroupUserDataDirectoryURL)

            loadingMessage = "方案部署中"

            // Rime重新部署
            rimeEngine.startRime(nil, fullCheck: true)
            if let schema = rimeEngine.getSchemas().first {
              appSettings.rimeInputSchema = schema.schemaId
            }
            rimeEngine.shutdownRime()
            appSettings.rimeNeedOverrideUserDataDirectory = true

            loadingMessage = "部署完毕"

            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
              launchScreenState = false
            }
          } catch {
            // 处理错误
            Logger.shared.log.debug("zip \(error)")
            showError = true
            err = ZipParsingError(message: "Zip文件处理失败: \(error.localizedDescription)")
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
