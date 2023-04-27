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
          LaunchScreen(loadingMessage: $loadingMessage)
        } else {
          ContentView()
        }
      }
      .onOpenURL { url in
        Logger.shared.log.info("open url: \(url)")

        if url.pathExtension.lowercased() == "zip" {
          // Loading: 开启加载页面
          launchScreenState = true
          loadingMessage = "Zip文件解析中..."
          do {
            let (handled, zipErr) = try RimeEngine.unzipUserData(url)
            if !handled {
              showError = true
              err = zipErr
              return
            }
          } catch {
            // 处理错误
            Logger.shared.log.error("zip \(error)")
            showError = true
            err = ZipParsingError(message: "Zip文件处理失败: \(error.localizedDescription)")
          }

          loadingMessage = "方案部署中"

          // Rime重新部署
          rimeEngine.startRime(nil, fullCheck: true)

          appSettings.rimeUserSelectSchema = []
          appSettings.rimeInputSchema = ""
          rimeEngine.initAppSettingRimeInputSchema(appSettings)

          rimeEngine.shutdownRime()
          appSettings.rimeNeedOverrideUserDataDirectory = true

          loadingMessage = "部署完毕"

          rimeEngine.shutdownRime()
          DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            launchScreenState = false
          }
        }
      }
      .onAppear {
        DispatchQueue.global().async {
          // 检测应用是否首次加载
          if appSettings.isFirstLaunch {
            loadingMessage = "初次启动，需要编译输入方案，请耐心等待……"

            // 加载系统默认配置上下滑动符号
            appSettings.keyboardSwipeGestureSymbol = Plist.defaultAction

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

            appSettings.isFirstLaunch = false
            appSettings.rimeNeedOverrideUserDataDirectory = true

            loadingMessage = "RIME部署完毕"

          } else {
            rimeEngine.setupRime(
              sharedSupportDir: RimeEngine.appGroupSharedSupportDirectoryURL.path,
              userDataDir: RimeEngine.appGroupUserDataDirectoryURL.path
            )
            rimeEngine.startRime(nil, fullCheck: false)
          }

          // 初始化用户选择的Schema, 当前Schema, 防止首次启动键盘的时候没有输入选项
          rimeEngine.initAppSettingRimeInputSchema(appSettings)

          Logger.shared.log.info("appSettings rimeInputSchema: \(appSettings.rimeInputSchema)")
          Logger.shared.log.info("appSettings rimeUserSelectSchema: \(appSettings.rimeUserSelectSchema)")

          rimeEngine.shutdownRime()
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
