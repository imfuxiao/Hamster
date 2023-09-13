//
//  KeyboardLayoutViewController.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import HamsterUIKit
import UIKit

/// 键盘布局
class KeyboardLayoutViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private let layoutSettingsViewController: LayoutSettingsViewController
  private let rootView: KeyboardLayoutRootView
  private var subscriptions = Set<AnyCancellable>()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel
    self.rootView = KeyboardLayoutRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    self.layoutSettingsViewController = LayoutSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)

    super.init()
  }

  override func loadView() {
    super.loadView()

    title = "键盘布局"
    view = rootView

    keyboardSettingsViewModel.useKeyboardTypePublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        self.navigationController?.pushViewController(layoutSettingsViewController, animated: true)
      }
      .store(in: &subscriptions)
  }
}
