//
//  CustomKeyboardSettingsView.swift
//
//
//  Created by morse on 2023/9/14.
//

import HamsterUIKit
import UIKit

/// 自定义键盘设置
class CustomKeyboardSettingsView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  
  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel
    
    super.init(frame: .zero)
    
    backgroundColor = .green
  }
}
