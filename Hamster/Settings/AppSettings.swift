import Foundation

// 功能指令
enum FunctionalInstructions: String, CaseIterable, Equatable, Identifiable {
  var id: Self {
    self
  }

  case simplifiedTraditionalSwitch = "#繁简切换"
  case switchChineseOrEnglish = "#中英切换"
  case beginOfSentence = "#行首"
  case endOfSentence = "#行尾"
  case selectSecond = "#次选上屏"
  case selectInputSchema = "#方案切换"
  case selectColorSchema = "#配色切换"
  case none = "无"

  var text: String {
    switch self {
    case .simplifiedTraditionalSwitch:
      return "繁"
    case .switchChineseOrEnglish:
      return "英"
    case .beginOfSentence:
      return "⇤"
    case .endOfSentence:
      return "⇥"
    case .selectSecond:
      return "次"
    default:
      return ""
    }
  }
}

public enum HapticIntensity: Int, CaseIterable, Equatable, Identifiable {
  public var id: Int {
    return rawValue
  }

  case ultraLightImpact
  case lightImpact
  case mediumImpact
  case heavyImpact

  var text: String {
    switch self {
    case .ultraLightImpact:
      return "超轻"
    case .lightImpact:
      return "轻"
    case .mediumImpact:
      return "中"
    case .heavyImpact:
      return "强"
    }
  }
}

/// 应用设置配置

private enum HamsterAppSettingKeys: String {
  // App首次启动
  case appFirstLaunch = "app.launch.isFirst"

  // 是否显示按键气泡
  case showKeyPressBubble = "view.keyboard.showKeyPressBubble"

  // 切换繁体中文
  case switchTraditionalChinese = "view.keyboard.switchTraditionalChinese"

  // 空格划动
  case slideBySpaceButton = "view.keyboard.slideBySpaceButton"

  // 空格上划次选
  case selectSecondChoiceByUpSlideSpaceButton = "app.keyboard.selectSecondChoiceByUpSlideSpaceButton"

  // 是否开启键盘声音
  case enableKeyboardFeedbackSound = "app.keyboard.feedback.sound"

  // 是否开启键盘震动
  case enableKeyboardFeedbackHaptic = "app.keyboard.feedback.haptic"
  case keyboardFeedbackHapticIntensity = "app.keyboard.feedback.hapticIntensity"

  // 是否显示键盘收起按键
  case showKeyboardDismissButton = "app.keyboard.showDismissButton"

  // 是否显示空格左边按键
  case showSpaceLeftButton = "app.keyboard.showSpaceLeftButton"
  // 空格左边按键键值
  case spaceLeftButtonValue = "app.keyboard.spaceLeftButtonValue"

  // 是否显示空格右边按键
  case showSpaceRightButton = "app.keyboard.showSpaceRightButton"
  // 空格右边按键键值
  case spaceRightButtonValue = "app.keyboard.spaceRightButtonValue"

  // 是否显示空格右边中英文切换键
  case showSpaceRightSwitchLanguageButton = "app.keyboard.showSpaceRightSwitchLanguageButton"
  // 中英切换按键位于空格是否位于左侧
  case switchLanguageButtonInSpaceLeft = "app.keyboard.switchLanguageButtonInSpaceLeft"

  // rime 候选字最大数量
  case rimeMaxCandidateSize = "rime.maxCandidateSize"

  // rime 候选字Title字体大小
  case rimeCandidateTitleFontSize = "rime.candidateTitleFontSize"
  case rimeCandidateCommentFontSize = "rime.candidateCommentFontSize"

  // rime 输入方案
  case rimeInputSchema = "rime.inputSchema"

  // rime 颜色方案
  case rimeEnableColorSchema = "rime.enableColorSchema"
  case rimeColorSchema = "rime.colorSchema"

  // rime 是否需要重新同步用户目录
  case rimeNeedOverrideUserDataDirectory = "rime.needOverrideUserDataDirectory"

  // 键盘上下滑动符号
  case enableKeyboardUpAndDownSlideSymbol = "keyboard.enableUpAndDownSlideSymbol"
  case showKeyboardUpAndDownSlideSymbol = "keyboard.showUpAndDownSlideSymbol"
  case keyboardUpAndDownSlideSymbol = "keyboard.upAndDownSlideSymbol"

  // 启用数字九宫格键盘
  case enableNumberNineGrid = "keyboard.enableNumberNineGrid"

  // 键盘是否自动小写
  case enableKeyboardAutomaticallyLowercase = "keyboard.enableKeyboardAutomaticallyLowercase"

  // 输入嵌入模式
  case enableInputEmbeddedMode = "keyboard.enableInputEmbeddedMode"

  // 使用鼠须管配置
  case rimeUseSquirrelSettings = "rime.useSquirrelSettings"
}

public class HamsterAppSettings: ObservableObject {
  let infoDictionary = Bundle.main.infoDictionary ?? [:]

  public init() {
    // 选项初始值
    UserDefaults.hamsterSettingsDefault.register(defaults: [
      HamsterAppSettingKeys.appFirstLaunch.rawValue: true,
      HamsterAppSettingKeys.showKeyPressBubble.rawValue: true,
      HamsterAppSettingKeys.switchTraditionalChinese.rawValue: false,
      HamsterAppSettingKeys.slideBySpaceButton.rawValue: true,
      HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue: false,
      HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue: false,
      HamsterAppSettingKeys.keyboardFeedbackHapticIntensity.rawValue: HapticIntensity.mediumImpact.rawValue,
      HamsterAppSettingKeys.showKeyboardDismissButton.rawValue: true,
      HamsterAppSettingKeys.showSpaceLeftButton.rawValue: true,
      HamsterAppSettingKeys.spaceLeftButtonValue.rawValue: ",",
      HamsterAppSettingKeys.showSpaceRightButton.rawValue: true,
      HamsterAppSettingKeys.showSpaceRightSwitchLanguageButton.rawValue: false,
      HamsterAppSettingKeys.switchLanguageButtonInSpaceLeft.rawValue: false,
      HamsterAppSettingKeys.spaceRightButtonValue.rawValue: ".",
      HamsterAppSettingKeys.rimeMaxCandidateSize.rawValue: 100,
      HamsterAppSettingKeys.rimeCandidateTitleFontSize.rawValue: 20,
      HamsterAppSettingKeys.rimeCandidateCommentFontSize.rawValue: 14,
      HamsterAppSettingKeys.rimeInputSchema.rawValue: "",
      HamsterAppSettingKeys.rimeEnableColorSchema.rawValue: false,
      HamsterAppSettingKeys.rimeColorSchema.rawValue: "",
      HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue: false,
      HamsterAppSettingKeys.enableKeyboardUpAndDownSlideSymbol.rawValue: true,
      HamsterAppSettingKeys.showKeyboardUpAndDownSlideSymbol.rawValue: true,
      HamsterAppSettingKeys.keyboardUpAndDownSlideSymbol.rawValue: [:] as [String: String],
      HamsterAppSettingKeys.enableNumberNineGrid.rawValue: false,
      HamsterAppSettingKeys.enableKeyboardAutomaticallyLowercase.rawValue: false,
      HamsterAppSettingKeys.enableInputEmbeddedMode.rawValue: false,
      HamsterAppSettingKeys.rimeUseSquirrelSettings.rawValue: true,
    ])

    self.isFirstLaunch = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.appFirstLaunch.rawValue)
    self.showKeyPressBubble = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)
    self.switchTraditionalChinese = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)
    self.slideBySpaceButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue)
    self.enableKeyboardFeedbackSound = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue)
    self.enableKeyboardFeedbackHaptic = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue)
    self.keyboardFeedbackHapticIntensity = UserDefaults.hamsterSettingsDefault.integer(forKey: HamsterAppSettingKeys.keyboardFeedbackHapticIntensity.rawValue)
    self.showKeyboardDismissButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyboardDismissButton.rawValue)
    self.showSpaceLeftButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showSpaceLeftButton.rawValue)
    self.spaceLeftButtonValue = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.spaceLeftButtonValue.rawValue) ?? ""
    self.showSpaceRightButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showSpaceRightButton.rawValue)
    self.spaceRightButtonValue = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.spaceRightButtonValue.rawValue) ?? ""
    self.showSpaceRightSwitchLanguageButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showSpaceRightSwitchLanguageButton.rawValue)
    self.switchLanguageButtonInSpaceLeft = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.switchLanguageButtonInSpaceLeft.rawValue)
    self.rimeMaxCandidateSize = Int32(UserDefaults.hamsterSettingsDefault.integer(forKey: HamsterAppSettingKeys.rimeMaxCandidateSize.rawValue))
    self.rimeCandidateTitleFontSize = UserDefaults.hamsterSettingsDefault.integer(forKey: HamsterAppSettingKeys.rimeCandidateTitleFontSize.rawValue)
    self.rimeCandidateCommentFontSize = UserDefaults.hamsterSettingsDefault.integer(forKey: HamsterAppSettingKeys.rimeCandidateCommentFontSize.rawValue)
    self.rimeInputSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue) ?? ""
    self.enableRimeColorSchema = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
    self.rimeColorSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue) ?? ""
    self.rimeNeedOverrideUserDataDirectory = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue)
    self.enableKeyboardUpAndDownSlideSymbol = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardUpAndDownSlideSymbol.rawValue)
    self.showKeyboardUpAndDownSlideSymbol = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyboardUpAndDownSlideSymbol.rawValue)
    self.keyboardUpAndDownSlideSymbol = UserDefaults.hamsterSettingsDefault.object(forKey: HamsterAppSettingKeys.keyboardUpAndDownSlideSymbol.rawValue) as! [String: String]
    self.enableNumberNineGrid = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableNumberNineGrid.rawValue)
    self.enableKeyboardAutomaticallyLowercase = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardAutomaticallyLowercase.rawValue)
    self.enableInputEmbeddedMode = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableInputEmbeddedMode.rawValue)
    self.rimeUseSquirrelSettings = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeUseSquirrelSettings.rawValue)
  }

  // App是否首次运行
  @Published
  var isFirstLaunch: Bool {
    didSet {
      Logger.shared.log.debug(["AppSettings, isFirstLaunch": isFirstLaunch])
      UserDefaults.hamsterSettingsDefault.set(
        isFirstLaunch, forKey: HamsterAppSettingKeys.appFirstLaunch.rawValue)
    }
  }

  // 按键气泡
  @Published
  var showKeyPressBubble: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, showKeyPressBubble": showKeyPressBubble])
      UserDefaults.hamsterSettingsDefault.set(
        showKeyPressBubble, forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)
    }
  }

  // 简繁切换
  @Published
  var switchTraditionalChinese: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, switchTraditionalChinese": switchTraditionalChinese])
      UserDefaults.hamsterSettingsDefault.set(
        switchTraditionalChinese, forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)
    }
  }

  // 空格滑动
  @Published
  var slideBySpaceButton: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, slideBySapceButton": slideBySpaceButton])
      UserDefaults.hamsterSettingsDefault.set(
        slideBySpaceButton, forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue)
    }
  }

  // 是否开启键盘声音
  @Published
  var enableKeyboardFeedbackSound: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableKeyboardFeedbackSound": enableKeyboardFeedbackSound])
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardFeedbackSound, forKey: HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue)
    }
  }

  // 是否开启键盘震动
  @Published
  var enableKeyboardFeedbackHaptic: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableKeyboardFeedbackHaptic": enableKeyboardFeedbackHaptic])
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardFeedbackHaptic, forKey: HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue)
    }
  }

  // 键盘震动强度
  @Published
  var keyboardFeedbackHapticIntensity: Int {
    didSet {
      Logger.shared.log.info(["AppSettings, keyboardFeedbackHapticIntensity": keyboardFeedbackHapticIntensity])
      UserDefaults.hamsterSettingsDefault.set(
        keyboardFeedbackHapticIntensity, forKey: HamsterAppSettingKeys.keyboardFeedbackHapticIntensity.rawValue)
    }
  }

  // 是否显示键盘收起按键
  @Published
  var showKeyboardDismissButton: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, showKeyboardDismissButton": showKeyboardDismissButton])
      UserDefaults.hamsterSettingsDefault.set(
        showKeyboardDismissButton, forKey: HamsterAppSettingKeys.showKeyboardDismissButton.rawValue)
    }
  }

  // 是否显示空格左边按键
  @Published
  var showSpaceLeftButton: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, showSpaceLeftButton": showSpaceLeftButton])
      UserDefaults.hamsterSettingsDefault.set(
        showSpaceLeftButton, forKey: HamsterAppSettingKeys.showSpaceLeftButton.rawValue)
    }
  }

  // 空格左边按键键值
  @Published
  var spaceLeftButtonValue: String {
    didSet {
      Logger.shared.log.info(["AppSettings, spaceLeftButtonValue": spaceLeftButtonValue])
      UserDefaults.hamsterSettingsDefault.set(
        spaceLeftButtonValue, forKey: HamsterAppSettingKeys.spaceLeftButtonValue.rawValue)
    }
  }

  // 是否显示空格右边按键
  @Published
  var showSpaceRightButton: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, showSpaceRightButton": showSpaceRightButton])
      UserDefaults.hamsterSettingsDefault.set(
        showSpaceRightButton, forKey: HamsterAppSettingKeys.showSpaceRightButton.rawValue)
    }
  }

  // 空格右边按键键值
  @Published
  var spaceRightButtonValue: String {
    didSet {
      Logger.shared.log.info(["AppSettings, spaceRightButtonValue": spaceRightButtonValue])
      UserDefaults.hamsterSettingsDefault.set(
        spaceRightButtonValue, forKey: HamsterAppSettingKeys.spaceRightButtonValue.rawValue)
    }
  }

  // 是否显示空格右边中英切换按键
  @Published
  var showSpaceRightSwitchLanguageButton: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, showSpaceRightSwitchLanguageButton": showSpaceRightSwitchLanguageButton])
      UserDefaults.hamsterSettingsDefault.set(
        showSpaceRightSwitchLanguageButton, forKey: HamsterAppSettingKeys.showSpaceRightSwitchLanguageButton.rawValue)
    }
  }

  // 中英切换按键位于空格左侧: true = 左侧 false = 右侧
  @Published
  var switchLanguageButtonInSpaceLeft: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, switchLanguageButtonInSpaceLeft": switchLanguageButtonInSpaceLeft])
      UserDefaults.hamsterSettingsDefault.set(
        switchLanguageButtonInSpaceLeft, forKey: HamsterAppSettingKeys.switchLanguageButtonInSpaceLeft.rawValue)
    }
  }

  @Published
  var rimeMaxCandidateSize: Int32 {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeMaxCandidateSize": rimeMaxCandidateSize])
      UserDefaults.hamsterSettingsDefault.set(
        rimeMaxCandidateSize, forKey: HamsterAppSettingKeys.rimeMaxCandidateSize.rawValue)
    }
  }

  @Published
  var rimeCandidateTitleFontSize: Int {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeCandidateTitleFontSize": rimeCandidateTitleFontSize])
      UserDefaults.hamsterSettingsDefault.set(
        rimeCandidateTitleFontSize, forKey: HamsterAppSettingKeys.rimeCandidateTitleFontSize.rawValue)
    }
  }

  @Published
  var rimeCandidateCommentFontSize: Int {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeCandidateCommentFontSize": rimeCandidateCommentFontSize])
      UserDefaults.hamsterSettingsDefault.set(
        rimeCandidateCommentFontSize, forKey: HamsterAppSettingKeys.rimeCandidateCommentFontSize.rawValue)
    }
  }

  // Rime: 输入方案
  @Published
  var rimeInputSchema: String {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeInputSchema": rimeInputSchema])
      UserDefaults.hamsterSettingsDefault.set(
        rimeInputSchema, forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue)
      UserDefaults.hamsterSettingsDefault.synchronize()
    }
  }

  // Rime: 是否启用颜色方案
  @Published
  var enableRimeColorSchema: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableRimeColorSchema": enableRimeColorSchema])
      UserDefaults.hamsterSettingsDefault.set(
        enableRimeColorSchema, forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
    }
  }

  // Rime: 颜色方案
  @Published
  var rimeColorSchema: String {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeColorSchema": rimeColorSchema])
      UserDefaults.hamsterSettingsDefault.set(
        rimeColorSchema, forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue)
      UserDefaults.hamsterSettingsDefault.synchronize()
    }
  }

  // Rime: 是否需要覆盖UserData目录数据
  @Published
  var rimeNeedOverrideUserDataDirectory: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeNeedOverrideUserDataDirectory": rimeNeedOverrideUserDataDirectory])
      UserDefaults.hamsterSettingsDefault.set(
        rimeNeedOverrideUserDataDirectory, forKey: HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue)
    }
  }

  // 键盘: 是否启用上下滑动符号
  @Published
  var enableKeyboardUpAndDownSlideSymbol: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableKeyboardUpAndDownSlideSymbol": enableKeyboardUpAndDownSlideSymbol])
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardUpAndDownSlideSymbol, forKey: HamsterAppSettingKeys.enableKeyboardUpAndDownSlideSymbol.rawValue)
    }
  }

  // 键盘: 是否显示上下滑动符号
  @Published
  var showKeyboardUpAndDownSlideSymbol: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableKeyboardUpAndDownSlideSymbol": enableKeyboardUpAndDownSlideSymbol])
      UserDefaults.hamsterSettingsDefault.set(
        showKeyboardUpAndDownSlideSymbol, forKey: HamsterAppSettingKeys.showKeyboardUpAndDownSlideSymbol.rawValue)
    }
  }

  // 键盘: 按键对应上下滑动键值
  @Published
  var keyboardUpAndDownSlideSymbol: [String: String] {
    didSet {
      Logger.shared.log.info(["AppSettings, keyboardUpAndDownSlideSymbol": keyboardUpAndDownSlideSymbol])
      UserDefaults.hamsterSettingsDefault.set(
        keyboardUpAndDownSlideSymbol, forKey: HamsterAppSettingKeys.keyboardUpAndDownSlideSymbol.rawValue)
    }
  }

  // 键盘: 启用数字键盘九宫格布局
  @Published
  var enableNumberNineGrid: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableNumberNineGrid": enableNumberNineGrid])
      UserDefaults.hamsterSettingsDefault.set(
        enableNumberNineGrid, forKey: HamsterAppSettingKeys.enableNumberNineGrid.rawValue)
    }
  }

  // 键盘: 启用键盘自动转小写
  @Published
  var enableKeyboardAutomaticallyLowercase: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableKeyboardAutomaticallyLowercase": enableKeyboardAutomaticallyLowercase])
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardAutomaticallyLowercase, forKey: HamsterAppSettingKeys.enableKeyboardAutomaticallyLowercase.rawValue)
    }
  }

  // 键盘: 启用输入嵌入模式
  @Published
  var enableInputEmbeddedMode: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableInputEmbeddedMode": enableInputEmbeddedMode])
      UserDefaults.hamsterSettingsDefault.set(
        enableInputEmbeddedMode, forKey: HamsterAppSettingKeys.enableInputEmbeddedMode.rawValue)
    }
  }

  // 键盘当前状态
  @Published
  var keyboardStatus: HamsterKeyboardStatus = .normal

  // Rime: 使用鼠须管配置
  @Published
  var rimeUseSquirrelSettings: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeUseSquirrelSettings": rimeUseSquirrelSettings])
      UserDefaults.hamsterSettingsDefault.set(
        rimeUseSquirrelSettings, forKey: HamsterAppSettingKeys.rimeUseSquirrelSettings.rawValue)
    }
  }
}

public extension UserDefaults {
  static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!
}

/// 键盘状态
enum HamsterKeyboardStatus: Equatable {
  /// 正常情况, 即只显示键盘
  case normal
  /// 键盘区域展开候选文字
  case keyboardAreaToExpandCandidates
  /// 键盘区域调节高度
  case keyboardAreaAdjustmentHeight
  /// (输入)方案切换
  case switchInputSchema
  /// 配色切换
  case switchColorSchema
}
