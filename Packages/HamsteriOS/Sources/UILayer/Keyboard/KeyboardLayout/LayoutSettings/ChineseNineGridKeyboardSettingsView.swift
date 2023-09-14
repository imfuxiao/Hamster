//
//  ChineseNineGridKeyboardSettingsView.swift
//
//
//  Created by morse on 2023/9/14.
//

import HamsterUIKit
import UIKit

/// 中文九宫格键盘布局设置
class ChineseNineGridKeyboardSettingsView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: .zero)

    self.backgroundColor = .blue
  }
}
