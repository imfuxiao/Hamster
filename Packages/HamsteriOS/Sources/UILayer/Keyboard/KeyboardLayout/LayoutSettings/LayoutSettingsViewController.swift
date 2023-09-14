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

    keyboardSettingsViewModel.useKeyboardTypePublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        self.title = $0.label
        if $0.isChinesePrimaryKeyboard {
          self.view = self.chineseStanderSystemKeyboardSettingsView
        } else if $0.isChineseNineGrid {
          self.view = self.chineseNineGridKeyboardSettingsView
        } else {
          self.view = self.customKeyboardSettingsView
        }
        self.view.setNeedsLayout()
      }
      .store(in: &subscriptions)

    additionalSafeAreaInsets = .zero
  }

  override func loadView() {
    super.loadView()
  }
}
