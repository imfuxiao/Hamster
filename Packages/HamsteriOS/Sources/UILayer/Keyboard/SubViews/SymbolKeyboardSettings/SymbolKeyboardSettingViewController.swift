//
//  SymbolKeyboardSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//
import HamsterUIKit
import ProgressHUD
import UIKit

class SymbolKeyboardSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }
}

// MARK: override UIViewController

extension SymbolKeyboardSettingsViewController {
  override func loadView() {
    title = "符号键盘设置"
    view = SymbolKeyboardSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}
