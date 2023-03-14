import Foundation

/**
 应用设置配置
 */

enum HamsterAppSettingKeys: String {
  // 是否显示按键气泡
  case showKeyPressBubble = "view.keyboard.showKeyPressBubble"
        
  // 切换繁体中文
  case switchTraditionalChinese = "view.keyboard.switchTraditionalChinese"
        
  // 空格划动
  case slideBySpaceButton = "view.keyboard.slideBySpaceButton"
        
  // rime 输入方案
  case rimeInputSchema = "rime.inputSchema"
  
  // rime 颜色方案
  case rimeEnableColorSchema = "rime.enableColorSchema"
  case rimeColorSchema = "rime.colorSchema"
}

public class HamsterAppSettings: ObservableObject {
  init() {
    // 选项初始值
    UserDefaults.hamsterSettingsDefault.register(defaults: [
      HamsterAppSettingKeys.showKeyPressBubble.rawValue: true,
      HamsterAppSettingKeys.switchTraditionalChinese.rawValue: false,
      HamsterAppSettingKeys.slideBySpaceButton.rawValue: true,
      HamsterAppSettingKeys.rimeInputSchema.rawValue: "",
      HamsterAppSettingKeys.rimeEnableColorSchema.rawValue: false,
      HamsterAppSettingKeys.rimeColorSchema.rawValue: "",
    ])
  }
    
  // 按键气泡
  @Published
  var showKeyPressBubble: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue) {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(showKeyPressBubble, forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)
    }
  }
    
  // 简繁切换
  @Published
  var switchTraditionalChinese: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue) {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(switchTraditionalChinese, forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)
    }
  }
    
  // 空格滑动
  @Published
  var slideBySapceButton: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue) {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(slideBySapceButton, forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue)
    }
  }
    
  // Rime: 输入方案
  @Published
  var rimeInputSchema: String = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue) ?? "" {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(rimeInputSchema, forKey: HamsterAppSettingKeys.rimeInputSchema.rawValue)
    }
  }
  
  // Rime: 颜色方案
  @Published
  var rimeEnableColorSchema: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue) {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(rimeEnableColorSchema, forKey: HamsterAppSettingKeys.rimeEnableColorSchema.rawValue)
    }
  }

  @Published
  var rimeColorSchema: String = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue) ?? "" {
    didSet {
      UserDefaults.hamsterSettingsDefault.set(rimeColorSchema, forKey: HamsterAppSettingKeys.rimeColorSchema.rawValue)
    }
  }
}

public extension UserDefaults {
  static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!
}
