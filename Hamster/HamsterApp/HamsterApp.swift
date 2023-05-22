//
//  HamsterApp.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import LibrimeKit
import Plist
import SwiftUI
import SwiftyBeaver
import ZIPFoundation

@main
@available(iOS 14, *)
struct HamsterApp: App {
  @StateObject
  var appSettings = HamsterAppSettings()

  @StateObject
  var rimeContext = RimeContext()
  @State var cancelable = Set<AnyCancellable>()
  @State var launchScreenState = true
  @State var showError: Bool = false
  @State var err: Error?
  @State var loadingMessage: String = ""
  @State var isLoading = false
  @State var metadataProvider: MetadataProvider?

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
      .onDisappear {
        metadataProvider = nil
      }
      .customHud(isShow: $isLoading, message: $loadingMessage)
      .environmentObject(appSettings)
      .environmentObject(rimeContext)
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
    appSettings.$enableAppleCloud
      .receive(on: DispatchQueue.main)
      .sink {
        if $0 {
          Logger.shared.log.info("apple cloud MetadataProvider create.")
          self.metadataProvider = MetadataProvider()
        } else {
          self.metadataProvider = nil
        }
      }
      .store(in: &cancelable)

    DispatchQueue.global().async {
      let traits = Rime.createTraits(
        sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
        userDataDir: RimeContext.sandboxUserDataDirectory.path
      )

      // 检测应用是否首次加载
      if appSettings.isFirstLaunch {
        showLoadingMessage("初次启动，需要编译输入方案，请耐心等待……")

        // 加载系统默认配置上下滑动符号
        appSettings.keyboardSwipeGestureSymbol = Plist.defaultAction

        // RIME首次启动需要先初始化输入方案
        do {
          try RimeContext.initSandboxSharedSupportDirectory(override: true)
          try RimeContext.initSandboxUserDataDirectory(override: true)
        } catch {
          Logger.shared.log.error("rime init file directory error: \(error), \(error.localizedDescription)")
          withMainAsync {
            showError = true
            err = error
          }
        }

        DispatchQueue.main.async {
          appSettings.rimeNeedOverrideUserDataDirectory = true
          showLoadingMessage("方案部署中，请耐心等待……")
        }

        // 方案部署
        let deployHandled = Rime.shared.deploy(traits)
        Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

        // 部署后将方案copy至AppGroup下供keyboard使用
        try? RimeContext.syncSandboxSharedSupportDirectoryToApGroup(override: true)
        try? RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)

        DispatchQueue.main.async {
          let resetHandled = appSettings.resetRimeParameter()
          Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")
          appSettings.rimeNeedOverrideUserDataDirectory = true
          appSettings.isFirstLaunch = false
        }
      }

      // PATCH: 1.6.8 将方案路径改为应用的 Sandbox 下
      do {
        if !FileManager.default.fileExists(atPath: RimeContext.sandboxUserDataDirectory.path) {
          try RimeContext.syncAppGroupSharedSupportDirectoryToSandbox()
          try RimeContext.syncAppGroupUserDataDirectoryToSandbox()
        }
      } catch {
        Logger.shared.log.error("copy appGroup inputSchema error: \(error), \(error.localizedDescription)")
      }

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
          let (handled, zipErr) = try fm.unzip(
            url,
            dst: RimeContext.sandboxUserDataDirectory
          )
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

        let traits = Rime.createTraits(
          sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
          userDataDir: RimeContext.sandboxUserDataDirectory.path
        )
        let deployHandled = Rime.shared.deploy(traits)
        Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

        let restHandled = appSettings.resetRimeParameter()
        Logger.shared.log.debug("rimeEngine resetInputSchemaHandled handled \(restHandled)")

        try? RimeContext.syncAppGroupUserDataDirectoryToSandbox(override: true)

        showLoadingMessage("部署完毕")
        withMainAsync {
          isLoading = false
        }
      }
    }
  }
}
