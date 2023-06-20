//
//  SettingViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import Combine
import Foundation
import Plist
import ProgressHUD

class SettingViewModel {
  init(appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
  }
  
  private let appSettings: HamsterAppSettings
  private var metadataProvider: MetadataProvider?
  private var cancelable = Set<AnyCancellable>()
}

extension SettingViewModel {
  func backup() {
    ProgressHUD.show("软件备份中，请等待……", interaction: false)
    DispatchQueue.global().async { [unowned self] in
      do {
        try FileManager.default.hamsterBackup(appSettings: appSettings)
      } catch {
        Logger.shared.log.error("App backup error: \(error.localizedDescription)")
        ProgressHUD.showError("备份异常", interaction: false, delay: 1.5)
        return
      }
      ProgressHUD.showSuccess("备份成功", interaction: false, delay: 1.5)
    }
  }
  
  // App启动加载数据
  func appLoadData() {
    appSettings.$enableAppleCloud
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        if $0 {
          Logger.shared.log.info("apple cloud MetadataProvider create.")
          self.metadataProvider = MetadataProvider()
        } else {
          self.metadataProvider = nil
        }
      }
      .store(in: &cancelable)
    
    DispatchQueue.global().async { [unowned self] in
      let traits = Rime.createTraits(
        sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
        userDataDir: RimeContext.sandboxUserDataDirectory.path
      )
      
      // 检测应用是否首次加载
      if appSettings.isFirstLaunch {
        ProgressHUD.show("初次启动，需要编译输入方案，请耐心等待……", interaction: false)
        
        DispatchQueue.main.async { [unowned self] in
          // 加载系统默认配置上下滑动符号
          self.appSettings.keyboardSwipeGestureSymbol = Plist.defaultAction
        }
        
        // RIME首次启动需要先初始化输入方案
        do {
          try RimeContext.initSandboxSharedSupportDirectory(override: true)
          try RimeContext.initSandboxUserDataDirectory(override: true)
        } catch {
          Logger.shared.log.error("rime init file directory error: \(error), \(error.localizedDescription)")
          ProgressHUD.showError("初始化输入方案失败: \(error.localizedDescription)", interaction: false, delay: 3)
          return
        }
        
        DispatchQueue.main.async { [unowned self] in
          self.appSettings.rimeNeedOverrideUserDataDirectory = true
        }
        
        ProgressHUD.show("方案部署中，请耐心等待……", interaction: false)
        
        // 方案部署
        let deployHandled = Rime.shared.deploy(traits)
        Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")
        
        // 部署后将方案copy至AppGroup下供keyboard使用
        try? RimeContext.syncSandboxSharedSupportDirectoryToApGroup(override: true)
        try? RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)
        
        DispatchQueue.main.async { [unowned self] in
          let resetHandled = self.appSettings.resetRimeParameter()
          Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")
          self.appSettings.rimeNeedOverrideUserDataDirectory = true
          self.appSettings.isFirstLaunch = false
          ProgressHUD.showSucceed("部署完成", interaction: false, delay: 1.5)
        }
      }
    }
  }
}
