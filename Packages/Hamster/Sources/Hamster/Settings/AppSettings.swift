import Foundation
import SwiftUI

class HamsterAppSettings: ObservableObject {
  @Published var preferences = AppPreferences()
}

struct AppPreferences {
  @AppStorage(HamsterAppSettingKeys.isTraditionalChinese.rawValue, store: UserDefaults.hamsterSettingsDefault)
  var isTraditionalChinese: Bool = false

  @AppStorage(HamsterAppSettingKeys.slideBySpace.rawValue, store: UserDefaults.hamsterSettingsDefault)
  var useSpaceSlide: Bool = true
}

/**
 应用设置配置
 */
enum HamsterAppSettingKeys: String {
  case isTraditionalChinese
  case slideBySpace
}

extension UserDefaults {
  public static let hamsterSettingsDefault = UserDefaults(suiteName: AppConstants.appGroupName)!

  @objc dynamic var isTraditionalChinese: Bool {
    set {
      set(newValue, forKey: HamsterAppSettingKeys.isTraditionalChinese.rawValue)
    }
    get {
      return bool(forKey: HamsterAppSettingKeys.isTraditionalChinese.rawValue)
    }
  }

  @objc dynamic var slideBySpace: Bool {
    set {
      set(newValue, forKey: HamsterAppSettingKeys.slideBySpace.rawValue)
    }
    get {
      return bool(forKey: HamsterAppSettingKeys.slideBySpace.rawValue)
    }
  }
}
