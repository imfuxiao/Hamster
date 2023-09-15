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

  private var subscriptions = Set<AnyCancellable>()

  private lazy var rootView: KeyboardLayoutRootView = {
    let view = KeyboardLayoutRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  private lazy var layoutSettingsViewController: LayoutSettingsViewController = {
    let vc = LayoutSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return vc
  }()

  private lazy var keySwipeSettingsViewController: KeySwipeSettingsViewController = {
    let vc = KeySwipeSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return vc
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

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

    keyboardSettingsViewModel.keySwipeSettingsActionPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        keySwipeSettingsViewController.updateWithKey($0)
        self.navigationController?.pushViewController(keySwipeSettingsViewController, animated: true)
      }
      .store(in: &subscriptions)
  }
}
