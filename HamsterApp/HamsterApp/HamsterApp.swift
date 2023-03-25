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
  let appSettings = HamsterAppSettings()
  let rimeEngine = RimeEngine.shared

  @State var launchScreenState = true

  var body: some Scene {
    WindowGroup {
      ZStack {
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
        DispatchQueue.main.async {
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
              Logger.shared.log.error("rime init file drectory error: \(error), \(error.localizedDescription)")
              fatalError("unresolved error: \(error), \(error.localizedDescription)")
            }
            appSettings.isFirstLaunch = false
          }

          // RIME启动
          rimeEngine.setupRime(
            sharedSupportDir: RimeEngine.appGroupSharedSupportDirectoryURL.path,
            userDataDir: RimeEngine.appGroupUserDataDirectoryURL.path)
          rimeEngine.startRime()

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
