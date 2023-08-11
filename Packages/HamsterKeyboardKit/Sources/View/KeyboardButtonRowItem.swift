//
//  KeyboardButtonRowItem.swift
//
//
//  Created by morse on 2023/8/11.
//

import Combine
import UIKit

class KeyboardButtonRowItem: UIView {
  private let content: KeyboardButton
  private let item: KeyboardLayoutItem
  private let actionHandler: KeyboardActionHandler
  private let calloutContext: KeyboardCalloutContext?
  private let keyboardWidth: CGFloat
  private let inputWidth: CGFloat
  private let appearance: KeyboardAppearance
  private var keyboardContext: KeyboardContext

  @Published
  private var isPressed = false

  init(item: KeyboardLayoutItem,
       keyboardContext: KeyboardContext,
       actionHandler: KeyboardActionHandler,
       calloutContext: KeyboardCalloutContext?,
       keyboardWidth: CGFloat,
       inputWidth: CGFloat,
       appearance: KeyboardAppearance)
  {
    self.content = KeyboardButton(
      action: item.action,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      appearance: appearance)

    self.item = item
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    self.calloutContext = calloutContext
    self.keyboardWidth = keyboardWidth
    self.inputWidth = inputWidth
    self.appearance = appearance

    super.init(frame: .zero)

    setupContent()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupContent() {
    addSubview(content)
    let insets = item.insets
    content.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
      content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
      content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
      content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right),
    ])
  }
}
