//
//  ColorSchemaSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

protocol KeyboardColorViewModelFactory {
  func makeKeyboardColorViewModel() -> KeyboardColorViewModel
}

class KeyboardColorViewController: NibLessViewController {
  private let keyboardColorViewModel: KeyboardColorViewModel
  private let rootView: KeyboardColorRootView

  init(keyboardColorViewModelFactory: KeyboardColorViewModelFactory) {
    self.keyboardColorViewModel = keyboardColorViewModelFactory.makeKeyboardColorViewModel()
    self.rootView = KeyboardColorRootView(keyboardColorViewModel: keyboardColorViewModel)

    super.init()
  }
}

// MARK: override UIViewController

extension KeyboardColorViewController {
  override func loadView() {
    title = "键盘配色"
    view = rootView
  }
}
