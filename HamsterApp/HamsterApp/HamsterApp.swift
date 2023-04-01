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
          LaunchScreen()
        } else {
          ContentView()
        }
      }
      .onOpenURL { url in
        Logger.shared.log.debug("open url: \(url)")
      }
      .onAppear {
        DispatchQueue.main.async(qos: .background) {
          // 检测应用是否首次加载
          if appSettings.isFirstLaunch {
            // 加载系统默认配置上下滑动符号
            appSettings.keyboardUpAndDownSlideSymbol = Plist.defaultAction

            // RIME首次启动需要将输入方案copy到AppGroup共享目录下供Keyboard使用
            do {
              try RimeEngine.initAppGroupSharedSupportDirectory(override: true)
              try RimeEngine.initAppGroupUserDataDirectory(override: true)
              appSettings.isFirstLaunch = false
            } catch {
              appSettings.isFirstLaunch = true
              Logger.shared.log.error("rime init file drectory error: \(error), \(error.localizedDescription)")
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
