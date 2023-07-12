//
//  SymbolSettingsViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import HamsterUIKit
import UIKit

class SymbolSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }
}

extension SymbolSettingsViewController {
  override func loadView() {
    super.loadView()

    title = "符号设置"

    view = SymbolSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}
