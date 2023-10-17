//
//  KeyboardFeedbackViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

protocol KeyboardFeedbackViewModelFactory {
  func makeKeyboardFeedbackViewModel() -> KeyboardFeedbackViewModel
}

class KeyboardFeedbackViewController: NibLessViewController {
  private let keyboardFeedbackViewModel: KeyboardFeedbackViewModel

  init(keyboardFeedbackViewModelFactory: KeyboardFeedbackViewModelFactory) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModelFactory.makeKeyboardFeedbackViewModel()

    super.init()
  }

  override func loadView() {
    title = "键盘反馈"
    view = KeyboardFeedbackRootView(
      keyboardFeedbackViewModel: keyboardFeedbackViewModel
    )
  }
}
