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
  private var subscriptions = Set<AnyCancellable>()

  private lazy var chineseStanderSystemKeyboardSettingsView: ChineseStanderSystemKeyboardSettingsView = {
    let view = ChineseStanderSystemKeyboardSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()

    keyboardSettingsViewModel.useKeyboardTypePublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        self.title = $0.label
        self.view = self.chineseStanderSystemKeyboardSettingsView
        self.view.setNeedsLayout()
      }
      .store(in: &subscriptions)
  }

  override func loadView() {
    super.loadView()
  }
}
