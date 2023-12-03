//
//  SpaceSettingsViewController.swift
//
//
//  Created by morse on 2023/10/12.
//

import HamsterUIKit
import UIKit

/// 空格设置 ViewController
public class SpaceSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }

  override public func loadView() {
    view = SpaceSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    title = L10n.KB.spaceSettings
  }
}
