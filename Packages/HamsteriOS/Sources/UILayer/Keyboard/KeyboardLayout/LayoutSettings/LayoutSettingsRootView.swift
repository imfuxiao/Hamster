//
//  LayoutSettingsRootView.swift
//
//
//  Created by morse on 2023/9/13.
//

import HamsterKeyboardKit
import HamsterKit
import HamsterUIKit
import UIKit

class LayoutSettingsRootView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  private lazy var chineseKeyboard: UIView = {
    let view = UIView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .yellow
    view.isHidden = true
    return view
  }()

  private lazy var chineseNineGridKeyboard: UIView = {
    let view = UIView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .blue
    view.isHidden = true
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: .zero)

    addSubview(chineseKeyboard)
    addSubview(chineseNineGridKeyboard)

    NSLayoutConstraint.activate([
      chineseKeyboard.topAnchor.constraint(equalTo: topAnchor),
      chineseKeyboard.leadingAnchor.constraint(equalTo: leadingAnchor),
      chineseKeyboard.trailingAnchor.constraint(equalTo: trailingAnchor),
      chineseKeyboard.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),

      chineseNineGridKeyboard.topAnchor.constraint(equalTo: topAnchor),
      chineseNineGridKeyboard.leadingAnchor.constraint(equalTo: leadingAnchor),
      chineseNineGridKeyboard.trailingAnchor.constraint(equalTo: trailingAnchor),
      chineseNineGridKeyboard.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),
    ])

    let keyboardType = keyboardSettingsViewModel.useKeyboardType
    switch keyboardType {
    case .chinese:
      chineseKeyboard.isHidden = false
      chineseNineGridKeyboard.isHidden = true
    case .chineseNineGrid:
      chineseKeyboard.isHidden = true
      chineseNineGridKeyboard.isHidden = false
    default:
      return
    }
  }
}
