//
//  ToggleCustomTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import HamsterUIKit
import UIKit

class HapticFeedbackTableViewCell: NibLessTableViewCell {
  static let identifier = "HapticFeedbackTableViewCell"

  private let keyboardFeedbackViewModel: KeyboardFeedbackViewModel

  lazy var hapticFeedbackView: HapticFeedbackView = {
    let hapticFeedbackView = HapticFeedbackView(keyboardFeedbackViewModel: keyboardFeedbackViewModel)
    return hapticFeedbackView
  }()

  init(keyboardFeedbackViewModel: KeyboardFeedbackViewModel) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModel

    super.init(style: .default, reuseIdentifier: Self.identifier)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    contentView.addSubview(hapticFeedbackView)
  }
}
