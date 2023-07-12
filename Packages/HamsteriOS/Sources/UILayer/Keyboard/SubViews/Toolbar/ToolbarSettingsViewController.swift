//
//  CandidateTextBarSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

class ToolbarSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }

  override func loadView() {
    super.loadView()

    title = "候选栏"
    view = ToolbarSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}
