//
//  ToggleCustomTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import Combine
import HamsterUIKit
import UIKit

class HapticFeedbackTableViewCell: NibLessTableViewCell {
  static let identifier = "HapticFeedbackTableViewCell"

  private let keyboardFeedbackViewModel: KeyboardFeedbackViewModel

  init(keyboardFeedbackViewModel: KeyboardFeedbackViewModel) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModel

    super.init(style: .default, reuseIdentifier: Self.identifier)

    let hapticFeedbackView = HapticFeedbackView(keyboardFeedbackViewModel: keyboardFeedbackViewModel)
    contentView.addSubview(hapticFeedbackView)
    hapticFeedbackView.translatesAutoresizingMaskIntoConstraints = false
    let contentLayoutGuide = contentView.layoutMarginsGuide
    NSLayoutConstraint.activate([
      hapticFeedbackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
      hapticFeedbackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
      hapticFeedbackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
      hapticFeedbackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
    ])
  }
}
