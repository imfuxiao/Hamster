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
        
    // rime 选择方案
    case rimeSelectSchema = "rime.selectSchema"
}

public class HamsterAppSettings: ObservableObject {
    init() {
        // 选项初始值
        UserDefaults.hamsterSettingsDefault.register(defaults: [
            HamsterAppSettingKeys.showKeyPressBubble.rawValue: true,
            HamsterAppSettingKeys.switchTraditionalChinese.rawValue: false,
            HamsterAppSettingKeys.slideBySpaceButton.rawValue: true,
            HamsterAppSettingKeys.rimeSelectSchema.rawValue: ""
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
    
    // Rime: 输入方案选择
    @Published
    var rimeSelectSchema: String = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeSelectSchema.rawValue) ?? "" {
        didSet {
            UserDefaults.hamsterSettingsDefault.set(rimeSelectSchema, forKey: HamsterAppSettingKeys.rimeSelectSchema.rawValue)
        }
    }
}

public extension UserDefaults {
    static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!
}
