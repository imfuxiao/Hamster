//
//  SettingViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import Combine
import HamsterKeyboardKit
import HamsterKit
import OSLog
import ProgressHUD
import RimeKit
import UIKit

public class SettingsViewModel: ObservableObject {
  private var cancelable = Set<AnyCancellable>()
  private unowned let mainViewModel: MainViewModel
  private let rimeContext: RimeContext
  
  init(mainViewModel: MainViewModel, rimeContext: RimeContext) {
    self.mainViewModel = mainViewModel
    self.rimeContext = rimeContext
  }
  
  public var enableColorSchema: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableColorSchema ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableColorSchema = newValue
    }
  }
  
  public var enableAppleCloud: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.general?.enableAppleCloud ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.general?.enableAppleCloud = newValue
    }
  }
  
  /// 设置选项
  public lazy var sections: [SettingSectionModel] = {
    let sections = [
      SettingSectionModel(title: "输入相关", items: [
        .init(
          icon: UIImage(systemName: "highlighter")!.withTintColor(.yellow),
          text: "输入方案设置",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .inputSchema
          }
        ),
        .init(
          icon: UIImage(systemName: "network")!,
          text: "输入方案上传",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .uploadInputSchema
          }
        ),
        .init(
          icon: UIImage(systemName: "folder")!,
          text: "方案文件管理",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .finder
          }
        ),
      ]),
      SettingSectionModel(title: "键盘相关", items: [
        .init(
          icon: UIImage(systemName: "keyboard")!,
          text: "键盘设置",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .keyboardSettings
          }
        ),
        .init(
          icon: UIImage(systemName: "paintpalette")!,
          text: "键盘配色",
          accessoryType: .disclosureIndicator,
          navigationLinkLabel: { [unowned self] in enableColorSchema ? "启用" : "禁用" },
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .colorSchema
          }
        ),
        .init(
          icon: UIImage(systemName: "speaker.wave.3")!,
          text: "按键音与震动",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .feedback
          }
        ),
      ]),
      SettingSectionModel(title: "同步与备份", items: [
        .init(
          icon: UIImage(systemName: "externaldrive.badge.icloud")!,
          text: "iCloud同步",
          accessoryType: .disclosureIndicator,
          navigationLinkLabel: { [unowned self] in enableAppleCloud ? "启用" : "禁用" },
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .iCloud
          }
        ),
        .init(
          icon: UIImage(systemName: "externaldrive.badge.timemachine")!,
          text: "软件备份",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .backup
          }
        ),
      ]),
      .init(title: "RIME", items: [
        .init(
          icon: UIImage(systemName: "r.square")!,
          text: "RIME",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .rime
          }
        ),
      ]),
      .init(title: "关于", items: [
        .init(
          icon: UIImage(systemName: "info.circle")!,
          text: "关于",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subView = .about
          }
        ),
      ]),
    ]
    return sections
  }()
}

extension SettingsViewModel {
  /// 启动加载数据
  func loadAppData() async throws {
    // 判断应用是否首次运行
    guard UserDefaults.hamster.isFirstRunning else { return }
    
    // 判断是否首次运行
    await ProgressHUD.show("初次启动，需要编译输入方案，请耐心等待……", interaction: false)
        
    // 首次启动始化输入方案目录
    do {
      try FileManager.initSandboxUserDataDirectory(override: true)
      try FileManager.initSandboxBackupDirectory(override: true)
    } catch {
      Logger.statistics.error("rime init file directory error: \(error.localizedDescription)")
      throw error
    }
        
    // 部署 RIME
    try await rimeContext.deployment(configuration: HamsterAppDependencyContainer.shared.configuration)
      
    // 部署后将方案copy至AppGroup下供keyboard使用
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
      
    // 修改应用首次运行标志
    UserDefaults.hamster.isFirstRunning = false
      
    await ProgressHUD.showSucceed("部署完成", interaction: false, delay: 1.5)
  }
}
