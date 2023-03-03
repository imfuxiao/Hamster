import Foundation
import SwiftUI

/**
 应用设置配置
 */
class HamsterAppSettings: ObservableObject {
    @Published var preferences = AppPreferences()
}

struct AppPreferences {
    enum HamsterAppSettingKeys: String {
        case isTraditionalChinese
        case slideBySpace
        case displayPopupCharacter
        case useInsertSymbol

        case keyboardHaptic // 键盘震动
        case keyboardHapticStrength // 键盘震动强度
        case keyboardSound // 键盘声音
    }

    init() {
        // TODO: 选项初始化值
    }

    // 按键气泡
    @AppStorage(HamsterAppSettingKeys.displayPopupCharacter.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var showKeyPressBubble: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.displayPopupCharacter.rawValue)

    @AppStorage(HamsterAppSettingKeys.useInsertSymbol.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var useInsertSymbol: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.useInsertSymbol.rawValue)

    @AppStorage(HamsterAppSettingKeys.isTraditionalChinese.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var isTraditionalChinese: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.isTraditionalChinese.rawValue)

    @AppStorage(HamsterAppSettingKeys.slideBySpace.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var useSpaceSlide: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.slideBySpace.rawValue)

    @AppStorage(HamsterAppSettingKeys.keyboardHaptic.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var useKeyboardHaptic: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.keyboardHaptic.rawValue)

    @AppStorage(HamsterAppSettingKeys.keyboardSound.rawValue, store: UserDefaults.hamsterSettingsDefault)
    var useKeyboardSound: Bool = UserDefaults.hamsterSettingsDefault.bool(forKey: HamsterAppSettingKeys.keyboardSound.rawValue)
}

public extension UserDefaults {
    static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!
}
