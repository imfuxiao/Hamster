//
//  CandidateTextBarSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

public class ToolbarSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }

  override public func loadView() {
    title = L10n.KB.Toolbar.title
    view = ToolbarSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}
