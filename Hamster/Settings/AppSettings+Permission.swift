//
//  AppSettings+Permission.swift
//  Hamster
//
//  Created by morse on 2023/3/25.
//

import Foundation
import UIKit

extension HamsterAppSettings {
  // 检测键盘是否具有完全访问权限
  var hasFullAccess: Bool {
    UIInputViewController().hasFullAccess
  }

  // 检测输入法是否启用
  var isKeyboardEnabled: Bool {
    guard let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] else {
      return false
    }
    return keyboards.contains(AppConstants.keyboardBundleID)
  }
}
