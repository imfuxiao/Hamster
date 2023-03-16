import Foundation

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

  // 是否开启键盘声音
  case enableKeyboardFeedbackSound = "app.keyboard.feedback.sound"

  // 是否开启键盘震动
  case enableKeyboardFeedbackHaptic = "app.keyboard.feedback.haptic"

  // rime 输入方案
  case rimeInputSchema = "rime.inputSchema"

  // rime 颜色方案
  case rimeEnableColorSchema = "rime.enableColorSchema"
  case rimeColorSchema = "rime.colorSchema"

  // rime 是否需要重新同步用户目录
  case rimeNeedOverrideUserDataDirectory = "rime.needOverrideUserDataDirectory"
}

public class HamsterAppSettings: ObservableObject {
  init() {
    // 选项初始值
    UserDefaults.hamsterSettingsDefault.register(defaults: [
      HamsterAppSettingKeys.appFirstLaunch.rawValue: true,
      HamsterAppSettingKeys.showKeyPressBubble.rawValue: true,
      HamsterAppSettingKeys.switchTraditionalChinese.rawValue: false,
      HamsterAppSettingKeys.slideBySpaceButton.rawValue: true,
      HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue: false,
      HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue: false,
      HamsterAppSettingKeys.rimeInputSchema.rawValue: "",
      HamsterAppSettingKeys.rimeEnableColorSchema.rawValue: false,
      HamsterAppSettingKeys.rimeColorSchema.rawValue: "",
      HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue: false,
    ])

    self.isFirstLaunch = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.appFirstLaunch.rawValue)
    self.showKeyPressBubble = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)
    self.switchTraditionalChinese = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)
    self.slideBySapceButton = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue)
    self.enableKeyboardFeedbackSound = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue)
    self.enableKeyboardFeedbackHaptic = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue)
    self.rimeInputSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue) ?? ""
    self.rimeEnableColorSchema = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
    self.rimeColorSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue) ?? ""
    self.rimeNeedOverrideUserDataDirectory = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue)
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
  var rimeEnableColorSchema: Bool {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        rimeEnableColorSchema, forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
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
      UserDefaults.hamsterSettingsDefault.synchronize()
    }
  }
}

public extension UserDefaults {
  static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!
}
