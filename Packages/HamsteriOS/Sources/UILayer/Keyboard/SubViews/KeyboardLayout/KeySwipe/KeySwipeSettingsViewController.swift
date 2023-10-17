//
//  KeySwipeSettingsViewController.swift
//
//
//  Created by morse on 2023/9/15.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

class KeySwipeSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  private lazy var rootView: KeySwipeSettingsView = {
    let view = KeySwipeSettingsView(KeyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }

  override func loadView() {
    title = "划动设置"
    self.view = rootView
  }

  public func updateWithKey(_ key: Key?) {
    if let key = key {
      title = key.action.labelText
      rootView.updateWithKey(key)
    }
  }
}
