import Foundation
import SwiftUI

/**
 应用设置配置
 */
public class HamsterAppSettings: ObservableObject {
    @Published var preferences = AppPreferences()
}

struct AppPreferences {
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
    @AppStorage(HamsterAppSettingKeys.showKeyPressBubble.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var showKeyPressBubble: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.showKeyPressBubble.rawValue)

    // 简繁切换
    @AppStorage(HamsterAppSettingKeys.switchTraditionalChinese.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var switchTraditionalChinese: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.switchTraditionalChinese.rawValue)

    // 空格滑动
    @AppStorage(HamsterAppSettingKeys.slideBySpaceButton.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var slideBySapceButton: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.slideBySpaceButton.rawValue)

    // Rime: 输入方案选择
    @AppStorage(HamsterAppSettingKeys.rimeSelectSchema.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var rimeSelectSchema: String = UserDefaults.hamsterSettingsDefault.string(forKey: HamsterAppSettingKeys.rimeSelectSchema.rawValue) ?? ""
}

public extension UserDefaults {
    static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!
}
