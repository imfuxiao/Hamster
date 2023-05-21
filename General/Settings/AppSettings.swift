import Combine
import Foundation
import Yams

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
  case thirdlySecond = "#三选上屏"
  case selectInputSchema = "#方案切换"
  case selectColorSchema = "#配色切换"
  case newLine = "#换行"
  case deleteInputKey = "#清屏"
  case switchLastInputSchema = "#切换上个输入方案"
  case onehandOnLeft = "#左手模式"
  case onehandOnRight = "#右手模式"
  case rimeSwitcher = "#RimeSwitcher"
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
    case .onehandOnLeft:
      return "左"
    case .onehandOnRight:
      return "右"
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
  case enableSpaceSliding = "view.keyboard.enableSpaceSliding"

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

  // 全部颜色方案
  case rimeTotalColorSchemas = "rime.rimeTotalColorSchemas"

  // 全部输入方案
  case rimeTotalSchemas = "rime.rimeTotalSchemas"

  // 用户选择输入方案
  case rimeUserSelectSchema = "rime.rimeUserSelectSchema"

  // rime 输入方案
  case rimeInputSchema = "rime.inputSchema"
  // 最近一次使用的输入方案
  case lastUseRimeInputSchema = "rime.lastUseRimeInputSchema"

  // rime 颜色方案
  case rimeEnableColorSchema = "rime.enableColorSchema"
  case rimeColorSchema = "rime.colorSchema"

  // rime 是否需要重新同步用户目录
  case rimeNeedOverrideUserDataDirectory = "rime.needOverrideUserDataDirectory"

  // 键盘滑动手势对应的符号或功能
  case enableKeyboardSwipeGestureSymbol = "keyboard.enableSwipeGestureSymbol"
  case keyboardSwipeGestureSymbol = "keyboard.swipeGestureSymbol"

  // 按键副区域是否显示
  case showKeyExtensionArea = "keyboard.KeyExtensionArea"

  // 启用数字九宫格键盘
  case enableNumberNineGrid = "keyboard.enableNumberNineGrid"
  // 启用数字九宫格直接上屏模式
  case enableNumberNineGridInputOnScreenMode = "keyboard.enableNumberNineGridInputOnScreenMode"
  // 数字九宫格符号
  case numberNineGridSymbols = "keyboard.numberNineGridSymbols"

  // 键盘是否自动小写
  case enableKeyboardAutomaticallyLowercase = "keyboard.enableKeyboardAutomaticallyLowercase"

  // 输入嵌入模式
  case enableInputEmbeddedMode = "keyboard.enableInputEmbeddedMode"

  // 使用鼠须管配置
  case rimeUseSquirrelSettings = "rime.useSquirrelSettings"

  // x轴滑动灵敏度
  case xSwipeSensitivity = "keyboard.xSwipeSensitivity"

  // 是否开启单手键盘模式
  case enableKeyboardOneHandMode = "app.keyboard.enableKeyboardOnehandMode"

  // 是否开启单手模式-右手模式
  case keyboardOneHandOnRight = "app.keyboard.onehandModeIntensity"

  // 启用iCloud
  case enableAppleCloud = "app.enableAppleCloud"

  // copy 文件至云盘的文件名过滤正则表达式
  case copyToCloudFilterRegex = "app.copyToCloudFilterRegex"

  // 候选栏高度
  case candidateBarHeight = "app.keyboard.candidateBarHeight"

  // 候选栏开关
  case enableCandidateBar = "app.keyboard.enableCandidateBar"

  // 开启候选文字索引显示
  case enableShowCandidateIndex = "app.keyboard.enableShowCandidateIndex"
}

public class HamsterAppSettings: ObservableObject {
  let infoDictionary = Bundle.main.infoDictionary ?? [:]

  var cancelable = Set<AnyCancellable>()

  public init() {
    // 选项初始值
    UserDefaults.hamsterSettingsDefault.register(defaults: [
      HamsterAppSettingKeys.appFirstLaunch.rawValue: true,
      HamsterAppSettingKeys.showKeyPressBubble.rawValue: true,
      HamsterAppSettingKeys.switchTraditionalChinese.rawValue: false,
      HamsterAppSettingKeys.enableSpaceSliding.rawValue: true,
      HamsterAppSettingKeys.enableKeyboardFeedbackSound.rawValue: false,
      HamsterAppSettingKeys.enableKeyboardFeedbackHaptic.rawValue: false,
      HamsterAppSettingKeys.keyboardFeedbackHapticIntensity.rawValue: HapticIntensity.mediumImpact.rawValue,
      HamsterAppSettingKeys.showKeyboardDismissButton.rawValue: true,
      HamsterAppSettingKeys.showSpaceLeftButton.rawValue: true,
      HamsterAppSettingKeys.spaceLeftButtonValue.rawValue: ",",
      HamsterAppSettingKeys.showSpaceRightButton.rawValue: false,
      HamsterAppSettingKeys.showSpaceRightSwitchLanguageButton.rawValue: true,
      HamsterAppSettingKeys.spaceRightButtonValue.rawValue: ".",
      HamsterAppSettingKeys.switchLanguageButtonInSpaceLeft.rawValue: false,
      HamsterAppSettingKeys.rimeMaxCandidateSize.rawValue: 100,
      HamsterAppSettingKeys.rimeCandidateTitleFontSize.rawValue: 20,
      HamsterAppSettingKeys.rimeCandidateCommentFontSize.rawValue: 14,
      HamsterAppSettingKeys.rimeInputSchema.rawValue: "",
      HamsterAppSettingKeys.rimeTotalColorSchemas.rawValue: [] as [ColorSchema],
      HamsterAppSettingKeys.rimeTotalSchemas.rawValue: [] as [Schema],
      HamsterAppSettingKeys.rimeUserSelectSchema.rawValue: [] as [Schema],
      HamsterAppSettingKeys.lastUseRimeInputSchema.rawValue: "",
      HamsterAppSettingKeys.rimeEnableColorSchema.rawValue: false,
      HamsterAppSettingKeys.rimeColorSchema.rawValue: "",
      HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue: false,
      HamsterAppSettingKeys.enableKeyboardSwipeGestureSymbol.rawValue: true,
      HamsterAppSettingKeys.showKeyExtensionArea.rawValue: true,
      HamsterAppSettingKeys.keyboardSwipeGestureSymbol.rawValue: [:] as [String: String],
      HamsterAppSettingKeys.enableNumberNineGrid.rawValue: false,
      HamsterAppSettingKeys.enableNumberNineGridInputOnScreenMode.rawValue: true,
      HamsterAppSettingKeys.numberNineGridSymbols.rawValue: ["+", "-", "×", "÷", "%", "@"] as [String],
      HamsterAppSettingKeys.enableKeyboardAutomaticallyLowercase.rawValue: false,
      HamsterAppSettingKeys.enableInputEmbeddedMode.rawValue: false,
      HamsterAppSettingKeys.rimeUseSquirrelSettings.rawValue: true,
      HamsterAppSettingKeys.xSwipeSensitivity.rawValue: 20,
      HamsterAppSettingKeys.enableKeyboardOneHandMode.rawValue: false,
      HamsterAppSettingKeys.keyboardOneHandOnRight.rawValue: true,
      HamsterAppSettingKeys.enableAppleCloud.rawValue: false,
      HamsterAppSettingKeys.copyToCloudFilterRegex.rawValue: "",
      HamsterAppSettingKeys.candidateBarHeight.rawValue: 50,
      HamsterAppSettingKeys.enableCandidateBar.rawValue: true,
      HamsterAppSettingKeys.enableShowCandidateIndex.rawValue: false,
    ])

    self.isFirstLaunch = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.appFirstLaunch.rawValue)
    self.showKeyPressBubble = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)
    self.switchTraditionalChinese = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)
    self.enableSpaceSliding = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableSpaceSliding.rawValue)
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
    self.xSwipeSensitivity = UserDefaults.hamsterSettingsDefault.integer(forKey: HamsterAppSettingKeys.xSwipeSensitivity.rawValue)

    // 对数组类型且为Struct值需要特殊处理
    if let data = UserDefaults.hamsterSettingsDefault.data(forKey: HamsterAppSettingKeys.rimeTotalColorSchemas.rawValue) {
      let array = try! PropertyListDecoder().decode([ColorSchema].self, from: data)
      self.rimeTotalColorSchemas = array
    } else {
      self.rimeTotalColorSchemas = []
    }

    // 对数组类型且为Struct值需要特殊处理
    if let data = UserDefaults.hamsterSettingsDefault.data(forKey: HamsterAppSettingKeys.rimeTotalSchemas.rawValue) {
      let array = try! PropertyListDecoder().decode([Schema].self, from: data)
      self.rimeTotalSchemas = array
    } else {
      self.rimeTotalSchemas = []
    }

    if let data = UserDefaults.hamsterSettingsDefault.data(forKey: HamsterAppSettingKeys.rimeUserSelectSchema.rawValue) {
      let array = try! PropertyListDecoder().decode([Schema].self, from: data)
      self.rimeUserSelectSchema = array
    } else {
      self.rimeUserSelectSchema = []
    }

    // TODO: 注意先后顺序 lastUseRimeInputSchema, rimeInputSchema
    // 因为 lastUseRimeInputSchema 会在 rimeInputSchema.willSet() 重新赋值
    self.lastUseRimeInputSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.lastUseRimeInputSchema.rawValue) ?? ""
    self.rimeInputSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue) ?? ""

    self.enableRimeColorSchema = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
    self.rimeColorSchema = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue) ?? ""
    self.rimeNeedOverrideUserDataDirectory = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeNeedOverrideUserDataDirectory.rawValue)
    self.enableKeyboardSwipeGestureSymbol = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardSwipeGestureSymbol.rawValue)
    self.showKeyExtensionArea = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyExtensionArea.rawValue)
    self.keyboardSwipeGestureSymbol = UserDefaults.hamsterSettingsDefault.object(forKey: HamsterAppSettingKeys.keyboardSwipeGestureSymbol.rawValue) as! [String: String]
    self.enableNumberNineGrid = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableNumberNineGrid.rawValue)
    self.enableNumberNineGridInputOnScreenMode = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableNumberNineGridInputOnScreenMode.rawValue)
    self.numberNineGridSymbols = UserDefaults.hamsterSettingsDefault.object(forKey: HamsterAppSettingKeys.numberNineGridSymbols.rawValue) as! [String]
    self.enableKeyboardAutomaticallyLowercase = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardAutomaticallyLowercase.rawValue)
    self.enableInputEmbeddedMode = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableInputEmbeddedMode.rawValue)
    self.rimeUseSquirrelSettings = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeUseSquirrelSettings.rawValue)
    self.enableKeyboardOneHandMode = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableKeyboardOneHandMode.rawValue)
    self.keyboardOneHandOnRight = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.keyboardOneHandOnRight.rawValue)
    self.enableAppleCloud = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableAppleCloud.rawValue)
    self.copyToCloudFilterRegex = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.copyToCloudFilterRegex.rawValue) ?? ""
    self.candidateBarHeight = CGFloat(UserDefaults.hamsterSettingsDefault.integer(forKey: HamsterAppSettingKeys.candidateBarHeight.rawValue))
    self.enableCandidateBar = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableCandidateBar.rawValue)
    self.enableShowCandidateIndex = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.enableShowCandidateIndex.rawValue)
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
  var enableSpaceSliding: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableSpaceSliding": enableSpaceSliding])
      UserDefaults.hamsterSettingsDefault.set(
        enableSpaceSliding, forKey: HamsterAppSettingKeys.enableSpaceSliding.rawValue)
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

  // 最大候选字的数量
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

  // Rime: 全部颜色方案
  @Published
  var rimeTotalColorSchemas: [ColorSchema] {
    didSet {
      if let data = try? PropertyListEncoder().encode(rimeTotalColorSchemas) {
        Logger.shared.log.info(["AppSettings, rimeTotalColorSchemas": rimeTotalColorSchemas])
        UserDefaults.hamsterSettingsDefault.set(
          data, forKey: HamsterAppSettingKeys.rimeTotalColorSchemas.rawValue)
      } else {
        Logger.shared.log.error("AppSettings, rimeTotalColorSchemas error")
      }
    }
  }

  // Rime: 全部输入方案
  @Published
  var rimeTotalSchemas: [Schema] {
    didSet {
      if let data = try? PropertyListEncoder().encode(rimeTotalSchemas) {
        Logger.shared.log.info(["AppSettings, rimeTotalSchemas": rimeTotalSchemas])
        UserDefaults.hamsterSettingsDefault.set(
          data, forKey: HamsterAppSettingKeys.rimeTotalSchemas.rawValue)
      } else {
        Logger.shared.log.error("AppSettings, rimeTotalSchemas error")
      }
    }
  }

  // Rime: 用户选择的输入方案
  @Published
  var rimeUserSelectSchema: [Schema] {
    didSet {
      if let data = try? PropertyListEncoder().encode(rimeUserSelectSchema) {
        Logger.shared.log.info(["AppSettings, rimeUserSelectSchema": rimeUserSelectSchema])
        UserDefaults.hamsterSettingsDefault.set(
          data, forKey: HamsterAppSettingKeys.rimeUserSelectSchema.rawValue)
      } else {
        Logger.shared.log.error("AppSettings, rimeUserSelectSchema error")
      }
    }
  }

  // Rime: 当前Rime输入方案
  @Published
  var rimeInputSchema: String {
    didSet {
      Logger.shared.log.info(["AppSettings, rimeInputSchema": rimeInputSchema])
      UserDefaults.hamsterSettingsDefault.set(
        rimeInputSchema, forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue)
      UserDefaults.hamsterSettingsDefault.synchronize()
    }
  }

  // 最近一次使用的rime输入方案
  @Published
  var lastUseRimeInputSchema: String {
    didSet {
      Logger.shared.log.info(["AppSettings, lastInputSchema": lastUseRimeInputSchema])
      UserDefaults.hamsterSettingsDefault.set(
        lastUseRimeInputSchema, forKey: HamsterAppSettingKeys.lastUseRimeInputSchema.rawValue)
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

  // 键盘: 是否启用键盘滑动手势
  @Published
  var enableKeyboardSwipeGestureSymbol: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableKeyboardSwipeGestureSymbol": enableKeyboardSwipeGestureSymbol])
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardSwipeGestureSymbol, forKey: HamsterAppSettingKeys.enableKeyboardSwipeGestureSymbol.rawValue)
    }
  }

  // 键盘: 按键滑动手势对应键值
  @Published
  var keyboardSwipeGestureSymbol: [String: String] {
    didSet {
      Logger.shared.log.info(["AppSettings, keyboardSwipeGestureSymbol": keyboardSwipeGestureSymbol])
      UserDefaults.hamsterSettingsDefault.set(
        keyboardSwipeGestureSymbol, forKey: HamsterAppSettingKeys.keyboardSwipeGestureSymbol.rawValue)
    }
  }

  // 键盘: 是否显示按键扩展区域
  @Published
  var showKeyExtensionArea: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, showKeyExtensionArea": showKeyExtensionArea])
      UserDefaults.hamsterSettingsDefault.set(
        showKeyExtensionArea, forKey: HamsterAppSettingKeys.showKeyExtensionArea.rawValue)
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

  // 键盘: 启用数字九宫格直接上屏模式
  @Published
  var enableNumberNineGridInputOnScreenMode: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableNumberNineGridInputOnScreenMode": enableNumberNineGridInputOnScreenMode])
      UserDefaults.hamsterSettingsDefault.set(
        enableNumberNineGridInputOnScreenMode, forKey: HamsterAppSettingKeys.enableNumberNineGridInputOnScreenMode.rawValue)
    }
  }

  // 键盘: 数字九宫格符号
  @Published
  var numberNineGridSymbols: [String] {
    didSet {
      Logger.shared.log.info(["AppSettings, numberNineGridSymbols": numberNineGridSymbols])
      UserDefaults.hamsterSettingsDefault.set(
        numberNineGridSymbols, forKey: HamsterAppSettingKeys.numberNineGridSymbols.rawValue)
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

  // 键盘当前状态: 无需持久化
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

  // X 轴滑动灵敏度
  @Published
  var xSwipeSensitivity: Int {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(
        xSwipeSensitivity, forKey: HamsterAppSettingKeys.xSwipeSensitivity.rawValue)
    }
  }

  // 键盘: 启用单手模式
  @Published
  var enableKeyboardOneHandMode: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableKeyboardOneHandMode": enableKeyboardOneHandMode])
      UserDefaults.hamsterSettingsDefault.set(
        enableKeyboardOneHandMode, forKey: HamsterAppSettingKeys.enableKeyboardOneHandMode.rawValue)
    }
  }

  // 键盘: 右单手模式
  @Published
  var keyboardOneHandOnRight: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, keyboardOneHandOnRight": keyboardOneHandOnRight])
      UserDefaults.hamsterSettingsDefault.set(
        keyboardOneHandOnRight, forKey: HamsterAppSettingKeys.keyboardOneHandOnRight.rawValue)
    }
  }

  // TODO: 单手模式宽度
  var keyboardOneHandWidth: CGFloat {
    72
  }

  // 启用iCloud
  @Published
  var enableAppleCloud: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableAppleCloud": enableAppleCloud])
      UserDefaults.hamsterSettingsDefault.set(
        enableAppleCloud, forKey: HamsterAppSettingKeys.enableAppleCloud.rawValue)
    }
  }

  // 文件拷贝正则过滤
  @Published
  var copyToCloudFilterRegex: String {
    didSet {
      Logger.shared.log.info(["AppSettings, copyToCloudFilterRegex": copyToCloudFilterRegex])
      UserDefaults.hamsterSettingsDefault.set(
        copyToCloudFilterRegex, forKey: HamsterAppSettingKeys.copyToCloudFilterRegex.rawValue)
    }
  }

  // 候选栏高度
  @Published
  var candidateBarHeight: CGFloat {
    didSet {
      Logger.shared.log.info(["AppSettings, candidateBarHeight": candidateBarHeight])
      UserDefaults.hamsterSettingsDefault.set(
        Int(candidateBarHeight), forKey: HamsterAppSettingKeys.candidateBarHeight.rawValue)
    }
  }

  // 候选栏开关
  @Published
  var enableCandidateBar: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableCandidateBar": enableCandidateBar])
      UserDefaults.hamsterSettingsDefault.set(
        enableCandidateBar, forKey: HamsterAppSettingKeys.enableCandidateBar.rawValue)
    }
  }

  // 是否显示候选文字索引
  @Published
  var enableShowCandidateIndex: Bool {
    didSet {
      Logger.shared.log.info(["AppSettings, enableShowCandidateIndex": enableShowCandidateIndex])
      UserDefaults.hamsterSettingsDefault.set(
        enableShowCandidateIndex, forKey: HamsterAppSettingKeys.enableShowCandidateIndex.rawValue)
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

extension HamsterAppSettings {
  // 候选栏按钮图片
  var candidateBarArrowButtonImageName: String {
    if keyboardStatus == .normal {
      return "chevron.down"
    }
    return "chevron.up"
  }

  // 候选栏显示分隔符号
  var showDivider: Bool {
    keyboardStatus == .normal ? true : false
  }

  // 上下滑动显示符号
  var buttonExtendCharacter: [String: [String]] {
    var buttonExtendCharacter: [String: [String]] = [:]

    let translateFunctionText = { (name: String) -> String in
      if name.hasPrefix("#"), let slidFunction = FunctionalInstructions(rawValue: name) {
        return slidFunction.text
      }
      return name
    }

    for (fullKey, fullValue) in keyboardSwipeGestureSymbol {
      let value = translateFunctionText(fullValue).trimmingCharacters(in: .whitespaces)
      guard !value.isEmpty else { continue }
      var key = fullKey
      let suffix = String(key.removeLast())

      // 上划
      if suffix == KeyboardConstant.Character.SlideUp {
        if let dictValue = buttonExtendCharacter[key] {
          buttonExtendCharacter[key] = ([value] + dictValue)
        } else {
          buttonExtendCharacter[key] = [value]
        }
        continue
      }

      // 下划
      if suffix == KeyboardConstant.Character.SlideDown {
        if let dictValue = buttonExtendCharacter[key] {
          buttonExtendCharacter[key] = (dictValue + [value])
        } else {
          buttonExtendCharacter[key] = [value]
        }
      }
    }
    return buttonExtendCharacter
  }
}

extension HamsterAppSettings {
  /// 重置输入方案相关参数
  func resetRimeParameter() -> Bool {
    // 注意关闭rime
    if !Rime.shared.isRunning() {
      Rime.shared.start(Rime.createTraits(
        sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
        userDataDir: RimeContext.sandboxUserDataDirectory.path), maintenance: true, fullCheck: true)
    }

    var rimeTotalSchemas = Rime.shared.getSchemas().sorted()
    if rimeTotalSchemas.isEmpty {
      rimeTotalSchemas = Rime.shared.getSelectedRimeSchema().sorted()
    }
    if rimeTotalSchemas.isEmpty {
      return false
    }
    self.rimeTotalSchemas = rimeTotalSchemas.reduce([] as [Schema]) {
      if $0.contains($1) {
        return $0
      } else {
        return $0 + [$1]
      }
    }

    // 判断当前输入方案是否存在于方案列表中,不存在则输入方案为当前方案中的第一位
    let firstInputSchema = rimeTotalSchemas.first { rimeInputSchema == $0.schemaId }
    if firstInputSchema == nil {
      rimeInputSchema = rimeTotalSchemas[0].schemaId
    }

    // 用户选择的方案列表
    if rimeUserSelectSchema.isEmpty {
      rimeUserSelectSchema = rimeTotalSchemas
    } else {
      // 取交集
      let intersection = Set(rimeUserSelectSchema).intersection(rimeTotalSchemas)
      if intersection.isEmpty {
        rimeUserSelectSchema = rimeTotalSchemas
      } else {
        rimeUserSelectSchema = Array(intersection)
      }
    }

    // 颜色方案
    let colorSchemas = Rime.shared.colorSchema(rimeUseSquirrelSettings)
    rimeTotalColorSchemas = colorSchemas

    // 键盘需要重新copy方案
    rimeNeedOverrideUserDataDirectory = true

    if Rime.shared.isRunning() {
      Rime.shared.shutdown()
    }
    return true
  }
}
