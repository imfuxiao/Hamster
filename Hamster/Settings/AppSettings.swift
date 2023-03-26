import Foundation

enum SlideFuction: String, CaseIterable, Equatable, Identifiable {
  var id: Self {
    self
  }

  case SimplifiedTraditionalSwitch = "#繁简切换"
  case ChineseEnglishSwitch = "#中英切换"
  case BeginOfSentence = "#行首"
  case EndOfSentence = "#行尾"
  case SelectSecond = "#次选上屏"
  case none = "无"

  var text: String {
    switch self {
    case .SimplifiedTraditionalSwitch:
      return "繁"
    case .ChineseEnglishSwitch:
      return "英"
    case .BeginOfSentence:
      return "⇤"
    case .EndOfSentence:
      return "⇥"
    case .SelectSecond:
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

  case lightImpact
  case mediumImpact
  case heavyImpact

  var text: String {
    switch self {
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

  // rime 输入方案
  case rimeInputSchema = "rime.inputSchema"

  // rime 颜色方案
  case rimeEnableColorSchema = "rime.enableColorSchema"
  case rimeColorSchema = "rime.colorSchema"

  // rime 是否需要重新同步用户目录
  case rimeNeedOverrideUserDataDirectory = "rime.needOverrideUserDataDirectory"

  // 键盘上下滑动符号
  case enablekeyboardUpAndDownSlideSymbol = "keyboard.enableUpAndDownSlideSymbol"
  case keyboardUpAndDownSlideSymbol = "keyboard.upAndDownSlideSymbol"
}

public class HamsterAppSettings: ObservableObject {
  let infoDictionary = Bundle.main.infoDictionary ?? [:]

  init() {
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
      HamsterAppSettingKeys.spaceLeftButtonValue.rawValue: "，",
      HamsterAppSettingKeys.showSpaceRightButton.rawValue: true,
      HamsterAppSettingKeys.spaceRightButtonValue.rawValue: "。",
      HamsterAppSettingKeys.rimeInputSchema.rawValue: "",
      HamsterAppSettingKeys.rimeEnableColorSchema.rawValue: false,
      HamsterAppSettingKeys.rimeColorSchema.rawValue: "",
      HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue: false,
      HamsterAppSettingKeys.enablekeyboardUpAndDownSlideSymbol.rawValue: true,
      HamsterAppSettingKeys.keyboardUpAndDownSlideSymbol.rawValue: [:]
    ])

    self.isFirstLaunch = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.appFirstLaunch.rawValue)
    self.showKeyPressBubble = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)
    self.switchTraditionalChinese = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)
    self.slideBySapceButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue)
    self.enableKeyboardFeedbackSound = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue)
    self.enableKeyboardFeedbackHaptic = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue)
    self.keyboardFeedbackHapticIntensity = UserDefaults.hamsterSettingsDefault.integer(forKey: HamsterAppSettingKeys.keyboardFeedbackHapticIntensity.rawValue)
    self.showKeyboardDismissButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyboardDismissButton.rawValue)
    self.showSpaceLeftButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showSpaceLeftButton.rawValue)
    self.spaceLeftButtonValue = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.spaceLeftButtonValue.rawValue) ?? ""
    self.showSpaceRightButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showSpaceRightButton.rawValue)
    self.spaceRightButtonValue = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.spaceRightButtonValue.rawValue) ?? ""
    self.rimeInputSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue) ?? ""
    self.enableRimeColorSchema = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
    self.rimeColorSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue) ?? ""
    self.rimeNeedOverrideUserDataDirectory = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue)
    self.enableKeyboardUpAndDownSlideSymbol = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enablekeyboardUpAndDownSlideSymbol.rawValue)
    self.keyboardUpAndDownSlideSymbol = UserDefaults.hamsterSettingsDefault.object(forKey: HamsterAppSettingKeys.keyboardUpAndDownSlideSymbol.rawValue) as! [String: String]
  }

  // App是否首次运行
  @Published
  var isFirstLaunch: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        isFirstLaunch, forKey: HamsterAppSettingKeys.appFirstLaunch.rawValue)
    }
  }

  // 按键气泡
  @Published
  var showKeyPressBubble: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        showKeyPressBubble, forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)
    }
  }

  // 简繁切换
  @Published
  var switchTraditionalChinese: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        switchTraditionalChinese, forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)
    }
  }

  // 空格滑动
  @Published
  var slideBySapceButton: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        slideBySapceButton, forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue)
    }
  }

  // 是否开启键盘声音
  @Published
  var enableKeyboardFeedbackSound: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardFeedbackSound, forKey: HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue)
    }
  }

  // 是否开启键盘震动
  @Published
  var enableKeyboardFeedbackHaptic: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardFeedbackHaptic, forKey: HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue)
    }
  }

  // 键盘震动强度
  @Published
  var keyboardFeedbackHapticIntensity: Int {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        keyboardFeedbackHapticIntensity, forKey: HamsterAppSettingKeys.keyboardFeedbackHapticIntensity.rawValue)
    }
  }

  // 是否显示键盘收起键
  @Published
  var showKeyboardDismissButton: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        showKeyboardDismissButton, forKey: HamsterAppSettingKeys.showKeyboardDismissButton.rawValue)
    }
  }

  // 是否显示空格左边按键
  @Published
  var showSpaceLeftButton: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        showSpaceLeftButton, forKey: HamsterAppSettingKeys.showSpaceLeftButton.rawValue)
    }
  }

  // 空格左边按键键值
  @Published
  var spaceLeftButtonValue: String {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        spaceLeftButtonValue, forKey: HamsterAppSettingKeys.spaceLeftButtonValue.rawValue)
    }
  }

  // 是否显示空格右边按键
  @Published
  var showSpaceRightButton: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        showSpaceRightButton, forKey: HamsterAppSettingKeys.showSpaceRightButton.rawValue)
    }
  }

  // 空格右边按键键值
  @Published
  var spaceRightButtonValue: String {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        spaceRightButtonValue, forKey: HamsterAppSettingKeys.spaceRightButtonValue.rawValue)
    }
  }

  // Rime: 输入方案
  @Published
  var rimeInputSchema: String {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        rimeInputSchema, forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue)
    }
  }

  // Rime: 颜色方案
  @Published
  var enableRimeColorSchema: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        enableRimeColorSchema, forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
    }
  }

  @Published
  var rimeColorSchema: String {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        rimeColorSchema, forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue)
    }
  }

  // Rime: 是否需要覆盖rime UserData目录数据
  @Published
  var rimeNeedOverrideUserDataDirectory: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        rimeNeedOverrideUserDataDirectory, forKey: HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue)
    }
  }

  // 键盘: 上下滑动符号

  @Published
  var enableKeyboardUpAndDownSlideSymbol: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardUpAndDownSlideSymbol, forKey: HamsterAppSettingKeys.enablekeyboardUpAndDownSlideSymbol.rawValue)
    }
  }

  @Published
  var keyboardUpAndDownSlideSymbol: [String: String] {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        keyboardUpAndDownSlideSymbol, forKey: HamsterAppSettingKeys.keyboardUpAndDownSlideSymbol.rawValue)
    }
  }
}

public extension UserDefaults {
  static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!
}
