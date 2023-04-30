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
  @State var isLoading = false

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
      .onOpenURL(perform: openURL)
      .onAppear(perform: appLoadData)
      .hud(isShow: $isLoading, message: $loadingMessage)
      .environmentObject(appSettings)
      .environmentObject(rimeEngine)
    }
  }

  func showLoadingMessage(_ message: String) {
    withMainAsync {
      self.loadingMessage = message
    }
  }

  func withMainAsync(_ asyncFunc: @escaping () -> Void) {
    DispatchQueue.main.async(execute: DispatchWorkItem(block: asyncFunc))
  }

  // App加载数据
  func appLoadData() {
    DispatchQueue.global().async {
      // 检测应用是否首次加载
      if appSettings.isFirstLaunch {
        showLoadingMessage("初次启动，需要编译输入方案，请耐心等待……")

        // 加载系统默认配置上下滑动符号
        appSettings.keyboardSwipeGestureSymbol = Plist.defaultAction

        // RIME首次启动需要将输入方案copy到AppGroup共享目录下供Keyboard使用, 同时创建用户数据目录
        do {
          try RimeEngine.initAppGroupSharedSupportDirectory(override: true)
          try RimeEngine.initAppGroupUserDataDirectory(override: true)
        } catch {
          Logger.shared.log.error("rime init file directory error: \(error), \(error.localizedDescription)")
          withMainAsync {
            showError = true
            err = error
          }
        }
      }

      rimeEngine.setupRime()

      // PATCH：1.6.5 升级时，之前版本没有增加 rimeTotalSchemas/rimeTotalColorSchemas 属性值
      if appSettings.isFirstLaunch || appSettings.rimeTotalColorSchemas.isEmpty {
        showLoadingMessage("方案部署中，请耐心等待……")
        let deployHandled = rimeEngine.deploy()
        Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")
        let resetHandled = appSettings.resetRimeParameter(rimeEngine)
        Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")
        appSettings.isFirstLaunch = false
        appSettings.rimeNeedOverrideUserDataDirectory = true
      }

      Logger.shared.log.debug("appSettings rimeInputSchema: \(appSettings.rimeInputSchema)")
      Logger.shared.log.debug("appSettings rimeUserSelectSchema: \(appSettings.rimeUserSelectSchema)")
      Logger.shared.log.debug("appSettings rimeTotalSchemas: \(appSettings.rimeTotalSchemas)")
      Logger.shared.log.debug("appSettings rimeTotalColorSchemas: \(appSettings.rimeTotalColorSchemas)")

      // 启动屏延迟
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        launchScreenState = false
      }
    }
  }

  // 外部调用App
  func openURL(_ url: URL) {
    Logger.shared.log.info("open url: \(url)")

    if url.pathExtension.lowercased() == "zip" {
      // Loading: 开启加载页面
      isLoading = true
      loadingMessage = "Zip文件解析中..."
      DispatchQueue.global().async {
        let fm = FileManager.default
        do {
          let (handled, zipErr) = try fm.unzip(url)
          if !handled {
            withMainAsync {
              showError = true
              err = zipErr
            }
            return
          }
        } catch {
          // 处理错误
          Logger.shared.log.error("zip \(error)")
          withMainAsync {
            showError = true
            err = ZipParsingError(message: "Zip文件处理失败: \(error.localizedDescription)")
          }
        }

        showLoadingMessage("方案部署中")

        let deployHandled = rimeEngine.deploy()
        Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

        let restHandled = appSettings.resetRimeParameter(rimeEngine)
        Logger.shared.log.debug("rimeEngine resetInputSchemaHandled handled \(restHandled)")

        rimeEngine.shutdownRime()

        showLoadingMessage("部署完毕")

        rimeEngine.shutdownRime()
        withMainAsync {
          isLoading = false
        }
      }
    }
  }
}
