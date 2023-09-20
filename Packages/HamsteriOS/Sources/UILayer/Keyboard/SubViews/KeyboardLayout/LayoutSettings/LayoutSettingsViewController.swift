//
//  LayoutSettingsViewController.swift
//
//
//  Created by morse on 2023/9/13.
//

import Combine
import HamsterUIKit
import UIKit

/// 布局设置
class LayoutSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  private lazy var chineseStanderSystemKeyboardSettingsView: ChineseStanderSystemKeyboardSettingsView = {
    let view = ChineseStanderSystemKeyboardSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  private lazy var chineseNineGridKeyboardSettingsView: ChineseNineGridKeyboardSettingsView = {
    let view = ChineseNineGridKeyboardSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  private lazy var customKeyboardSettingsView: CustomKeyboardSettingsView = {
    let view = CustomKeyboardSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let useKeyboardType = keyboardSettingsViewModel.useKeyboardType {
      self.title = useKeyboardType.label
      if useKeyboardType.isChinesePrimaryKeyboard {
        self.view = self.chineseStanderSystemKeyboardSettingsView
      } else if useKeyboardType.isChineseNineGrid {
        self.view = self.chineseNineGridKeyboardSettingsView
      } else {
        self.view = self.customKeyboardSettingsView
      }
    }
  }
}
