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
import UIKit

public class SettingsViewModel: ObservableObject {
  private var cancelable = Set<AnyCancellable>()
  private unowned let mainViewModel: MainViewModel
  private let rimeViewModel: RimeViewModel
  private let backupViewModel: BackupViewModel

  init(mainViewModel: MainViewModel, rimeViewModel: RimeViewModel, backupViewModel: BackupViewModel) {
    self.mainViewModel = mainViewModel
    self.rimeViewModel = rimeViewModel
    self.backupViewModel = backupViewModel
  }

  public var enableColorSchema: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.enableColorSchema ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.enableColorSchema = newValue
      HamsterAppDependencyContainer.shared.applicationConfiguration.keyboard?.enableColorSchema = newValue
    }
  }

  public var enableAppleCloud: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.general?.enableAppleCloud ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.general?.enableAppleCloud = newValue
      HamsterAppDependencyContainer.shared.applicationConfiguration.general?.enableAppleCloud = newValue
    }
  }

  var tableReloadSubject = PassthroughSubject<Bool, Never>()
  var tableReloadPublished: AnyPublisher<Bool, Never> {
    tableReloadSubject.eraseToAnyPublisher()
  }

  func reloadFavoriteButton() {
    let favoriteButtonSettings = getFavoriteButtons(buttons: UserDefaults.standard.getFavoriteButtons())
    guard !favoriteButtonSettings.isEmpty else { return }

    let sectionsContainerFavoriteButtons = sections[0].items[0].type == .button
    if sectionsContainerFavoriteButtons {
      sections[0].items = favoriteButtonSettings
    } else {
      sections = [SettingSectionModel(items: favoriteButtonSettings)] + sections
    }
  }

  func getFavoriteButtons(buttons: [FavoriteButton]) -> [SettingItemModel] {
    // 检测是否有收藏按钮，如果有则添加到初始化数据 settingsViewModel.sections 中
    // 注意：后续的动态变化将在 combine() 方法中，通过观测 UserDefaults.favoriteButtonSubject 值完成
    guard !buttons.isEmpty else { return [] }
    return buttons
      .compactMap {
        switch $0 {
        case .rimeDeploy: return SettingItemModel(
            text: "重新部署",
            type: .button,
            buttonAction: { [weak self] in
              guard let self = self else { return }
              await rimeViewModel.rimeDeploy()
              tableReloadSubject.send(true)
            },
            favoriteButton: .rimeDeploy
          )
        case .rimeSync: return SettingItemModel(
            text: "RIME同步",
            type: .button,
            buttonAction: { [weak self] in
              guard let self = self else { return }
              await rimeViewModel.rimeSync()
            },
            favoriteButton: .rimeSync
          )
        case .appBackup: return SettingItemModel(
            text: "应用备份",
            type: .button,
            buttonAction: { [weak self] in
              guard let self = self else { return }
              await backupViewModel.backup()
            },
            favoriteButton: .rimeSync
          )
        }
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
            self.mainViewModel.subViewSubject.send(.inputSchema)
          }
        ),
        .init(
          icon: UIImage(systemName: "wifi")!,
          text: "Wi-Fi上传方案",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.uploadInputSchema)
          }
        ),
        .init(
          icon: UIImage(systemName: "folder")!,
          text: "文件管理",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.finder)
          }
        ),
      ]),
      SettingSectionModel(title: "键盘相关", items: [
        .init(
          icon: UIImage(systemName: "keyboard")!,
          text: "键盘设置",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.keyboardSettings)
          }
        ),
        .init(
          icon: UIImage(systemName: "paintpalette")!,
          text: "键盘配色",
          accessoryType: .disclosureIndicator,
          navigationLinkLabel: { [unowned self] in enableColorSchema ? "启用" : "禁用" },
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.colorSchema)
          }
        ),
        .init(
          icon: UIImage(systemName: "speaker.wave.3")!,
          text: "按键音与震动",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.feedback)
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
            self.mainViewModel.subViewSubject.send(.iCloud)
          }
        ),
        .init(
          icon: UIImage(systemName: "externaldrive.badge.timemachine")!,
          text: "软件备份",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.backup)
          }
        ),
      ]),
      .init(title: "RIME", items: [
        .init(
          icon: UIImage(systemName: "r.square")!,
          text: "RIME",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.rime)
          }
        ),
      ]),
      .init(title: "关于", items: [
        .init(
          icon: UIImage(systemName: "info.circle")!,
          text: "关于",
          accessoryType: .disclosureIndicator,
          navigationAction: { [unowned self] in
            self.mainViewModel.subViewSubject.send(.about)
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
    // PATCH: 仓1.0版本处理
    if let v1FirstRunning = UserDefaults.hamster._firstRunningForV1, v1FirstRunning == false {
      await ProgressHUD.animate("迁移 1.0 配置中……", interaction: false)

      var appConfig = HamsterAppDependencyContainer.shared.applicationConfiguration

      // 读取 1.0 配置参数
      _setupConfigurationForV1Update(configuration: &appConfig)

      // merge 1.0 配置参数
      var configuration = HamsterAppDependencyContainer.shared.configuration
      configuration = try configuration.merge(with: appConfig, uniquingKeysWith: { _, appConfig in appConfig })

      // 部署 RIME
      try rimeViewModel.rimeContext.deployment(configuration: &configuration)

      // 修改应用首次运行标志
      UserDefaults.standard.isFirstRunning = false

      /// 删除 V1 标识
      UserDefaults.hamster._removeFirstRunningForV1()

      HamsterAppDependencyContainer.shared.configuration = configuration
      HamsterAppDependencyContainer.shared.applicationConfiguration = appConfig

      await ProgressHUD.success("迁移完成", interaction: false, delay: 1.5)
      return
    }

    // 判断应用是否首次运行
    guard UserDefaults.standard.isFirstRunning else { return }

    // 判断是否首次运行
    await ProgressHUD.animate("初次启动，需要编译输入方案，请耐心等待……", interaction: false)

    // 首次启动始化输入方案目录
    do {
      try FileManager.initSandboxUserDataDirectory(override: true, unzip: true)
      try FileManager.initSandboxBackupDirectory(override: true)
    } catch {
      Logger.statistics.error("rime init file directory error: \(error.localizedDescription)")
      throw error
    }

    var configuration = HamsterAppDependencyContainer.shared.configuration

    // 部署 RIME
    try rimeViewModel.rimeContext.deployment(configuration: &configuration)

    // TODO: 内置雾凇方案，将默认选择方案改为雾凇拼音
    let rimeSchema = RimeSchema(schemaId: "rime_ice", schemaName: "雾凇拼音")
    rimeViewModel.rimeContext.selectSchemas = [rimeSchema]
    rimeViewModel.rimeContext.currentSchema = rimeSchema

    // 修改应用首次运行标志
    UserDefaults.standard.isFirstRunning = false

    HamsterAppDependencyContainer.shared.configuration = configuration

    await ProgressHUD.success("部署完成", interaction: false, delay: 1.5)
  }

  /// 仓1.0迁移配置参数
  private func _setupConfigurationForV1Update(configuration: inout HamsterConfiguration) {
    if let _showKeyPressBubble = UserDefaults.hamster._showKeyPressBubble {
      configuration.keyboard?.displayButtonBubbles = _showKeyPressBubble
    }

    if let _enableKeyboardFeedbackSound = UserDefaults.hamster._enableKeyboardFeedbackSound {
      configuration.keyboard?.enableKeySounds = _enableKeyboardFeedbackSound
    }

    if let _enableKeyboardFeedbackHaptic = UserDefaults.hamster._enableKeyboardFeedbackHaptic {
      configuration.keyboard?.enableHapticFeedback = _enableKeyboardFeedbackHaptic
    }

    if let _showKeyboardDismissButton = UserDefaults.hamster._showKeyboardDismissButton {
      configuration.toolbar?.displayKeyboardDismissButton = _showKeyboardDismissButton
    }

    if let _showSemicolonButton = UserDefaults.hamster._showSemicolonButton {
      configuration.keyboard?.displaySemicolonButton = _showSemicolonButton
    }

    if let _showSpaceLeftButton = UserDefaults.hamster._showSpaceLeftButton {
      configuration.keyboard?.displaySpaceLeftButton = _showSpaceLeftButton
    }

    if let _spaceLeftButtonValue = UserDefaults.hamster._spaceLeftButtonValue {
      configuration.keyboard?.keyValueOfSpaceLeftButton = _spaceLeftButtonValue
    }

    if let _showSpaceRightButton = UserDefaults.hamster._showSpaceRightButton {
      configuration.keyboard?.displaySpaceRightButton = _showSpaceRightButton
    }

    if let _spaceRightButtonValue = UserDefaults.hamster._spaceRightButtonValue {
      configuration.keyboard?.keyValueOfSpaceRightButton = _spaceRightButtonValue
    }

    if let _showSpaceRightSwitchLanguageButton = UserDefaults.hamster._showSpaceRightSwitchLanguageButton {
      configuration.keyboard?.displayChineseEnglishSwitchButton = _showSpaceRightSwitchLanguageButton
    }

    if let _switchLanguageButtonInSpaceLeft = UserDefaults.hamster._switchLanguageButtonInSpaceLeft {
      configuration.keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = _switchLanguageButtonInSpaceLeft
    }

    if let _rimeMaxCandidateSize = UserDefaults.hamster._rimeMaxCandidateSize {
      configuration.rime?.maximumNumberOfCandidateWords = _rimeMaxCandidateSize
    }

    if let _rimeCandidateTitleFontSize = UserDefaults.hamster._rimeCandidateTitleFontSize {
      configuration.toolbar?.candidateWordFontSize = _rimeCandidateTitleFontSize
    }

    if let _rimeCandidateCommentFontSize = UserDefaults.hamster._rimeCandidateCommentFontSize {
      configuration.toolbar?.candidateCommentFontSize = _rimeCandidateCommentFontSize
    }

    if let _candidateBarHeight = UserDefaults.hamster._candidateBarHeight {
      configuration.toolbar?.heightOfToolbar = _candidateBarHeight
    }

    if let _rimeSimplifiedAndTraditionalSwitcherKey = UserDefaults.hamster._rimeSimplifiedAndTraditionalSwitcherKey {
      configuration.rime?.keyValueOfSwitchSimplifiedAndTraditional = _rimeSimplifiedAndTraditionalSwitcherKey
    }

    if let _enableInputEmbeddedMode = UserDefaults.hamster._enableInputEmbeddedMode {
      configuration.keyboard?.enableEmbeddedInputMode = _enableInputEmbeddedMode
    }

    if let _enableKeyboardAutomaticallyLowercase = UserDefaults.hamster._enableKeyboardAutomaticallyLowercase {
      configuration.keyboard?.lockShiftState = !_enableKeyboardAutomaticallyLowercase
    }

    if let _rimeSimplifiedAndTraditionalSwitcherKey = UserDefaults.hamster._rimeSimplifiedAndTraditionalSwitcherKey {
      configuration.rime?.keyValueOfSwitchSimplifiedAndTraditional = _rimeSimplifiedAndTraditionalSwitcherKey
    }

    if let _keyboardSwipeGestureSymbol = UserDefaults.hamster._keyboardSwipeGestureSymbol {
      let translateShortCommand = { (name: String) -> ShortcutCommand? in
        if name.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") {
          return ShortcutCommand(rawValue: name)
        }
        return nil
      }

      var keySwipeMap = [KeyboardAction: [KeySwipe]]()
      for (fullKey, fullValue) in _keyboardSwipeGestureSymbol {
        let value = fullValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { continue }

        var key = fullKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let suffix = String(key.removeLast())
        let action: KeyboardAction = .character(key.lowercased())

        var direction: KeySwipe.Direction
        switch suffix {
        case Self._SlideUp:
          direction = .up
        case Self._SlideDown:
          direction = .down
        case Self._SlideLeft:
          direction = .left
        case Self._SlideRight:
          direction = .right
        default: continue
        }

        var keySwipe: KeySwipe
        if let command = translateShortCommand(value) {
          keySwipe = KeySwipe(direction: direction, action: .shortCommand(command), label: .empty)
        } else {
          keySwipe = KeySwipe(direction: direction, action: .character(value), label: .empty)
        }

        if var value = keySwipeMap[action] {
          value.append(keySwipe)
          keySwipeMap[action] = value
        } else {
          keySwipeMap[action] = [keySwipe]
        }
      }

      let keys = keySwipeMap.map { key, value in Key(action: key, swipe: value) }
      if let index = configuration.swipe?.keyboardSwipe?.firstIndex(where: { $0.keyboardType?.isChinese ?? false }) {
        configuration.swipe?.keyboardSwipe?[index] = KeyboardSwipe(keyboardType: .chinese(.lowercased), keys: keys)
      } else {
        configuration.swipe?.keyboardSwipe?.append(KeyboardSwipe(keyboardType: .chinese(.lowercased), keys: keys))
      }
    }
  }
}

extension SettingsViewModel {
  static let _SlideUp = "↑" // 表示上滑 Upwards Arrow: https://www.compart.com/en/unicode/U+2191
  static let _SlideDown = "↓" // 表示下滑 Downwards Arrow: https://www.compart.com/en/unicode/U+2193
  static let _SlideLeft = "←" // 表示左滑 Leftwards Arrow: https://www.compart.com/en/unicode/U+2190
  static let _SlideRight = "→" // 表示右滑 Rightwards Arrow: https://www.compart.com/en/unicode/U+2192
}
