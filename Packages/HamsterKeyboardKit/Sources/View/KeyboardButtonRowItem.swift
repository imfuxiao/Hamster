//
//  KeyboardButtonRowItem.swift
//
//
//  Created by morse on 2023/8/11.
//

import Combine
import UIKit

class KeyboardButtonRowItem: UIView {
  public let row: Int
  public let column: Int
  public let isSpacer: Bool
  public let item: KeyboardLayoutItem

  private let content: KeyboardButton
  private let actionHandler: KeyboardActionHandler
  private let calloutContext: KeyboardCalloutContext?
  private let keyboardWidth: CGFloat
  private let inputWidth: CGFloat
  private let appearance: KeyboardAppearance
  private var keyboardContext: KeyboardContext

  @Published
  private var isPressed = false

  init(
    row: Int,
    column: Int,
    item: KeyboardLayoutItem,
    keyboardContext: KeyboardContext,
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext?,
    keyboardWidth: CGFloat,
    inputWidth: CGFloat,
    appearance: KeyboardAppearance)
  {
    self.row = row
    self.column = column
    self.isSpacer = item.action.isSpacer
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
    /// spacer 类型不可见
    alpha = isSpacer ? 0 : 1
    addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
    let insets = item.insets
    let constraints = [
      content.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
      content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
      content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
      content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
    ]
    NSLayoutConstraint.activate(constraints)
  }
}
