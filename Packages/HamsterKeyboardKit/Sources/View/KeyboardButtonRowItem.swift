//
//  KeyboardButtonRowItem.swift
//
//
//  Created by morse on 2023/8/11.
//

import Combine
import HamsterKit
import OSLog
import UIKit

class KeyboardButtonRowItem: UIView {
  public let row: Int
  public let column: Int
  public let isSpacer: Bool
  public let item: KeyboardLayoutItem

  private let content: KeyboardButton
  private let actionHandler: KeyboardActionHandler
  private let calloutContext: KeyboardCalloutContext
  private let appearance: KeyboardAppearance
  private var keyboardContext: KeyboardContext
  private var interfaceOrientation: InterfaceOrientation

  @Published
  private var isPressed = false
  public var topConstraint: NSLayoutConstraint?
  public var bottomConstraint: NSLayoutConstraint?
  public var leadingConstraint: NSLayoutConstraint?
  public var trailingConstraint: NSLayoutConstraint?

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  init(
    row: Int,
    column: Int,
    item: KeyboardLayoutItem,
    keyboardContext: KeyboardContext,
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext,
    appearance: KeyboardAppearance)
  {
    self.row = row
    self.column = column
    self.isSpacer = item.action.isSpacer

    self.content = KeyboardButton(
      row: row,
      column: column,
      item: item,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      appearance: appearance)

    self.item = item
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    self.calloutContext = calloutContext
    self.appearance = appearance
    self.interfaceOrientation = keyboardContext.interfaceOrientation

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
    let insets = layoutConfig.buttonInsets
    topConstraint = content.topAnchor.constraint(equalTo: topAnchor, constant: insets.top)
    bottomConstraint = content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
    leadingConstraint = content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left)
    trailingConstraint = content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
    NSLayoutConstraint.activate([topConstraint!, bottomConstraint!, leadingConstraint!, trailingConstraint!])
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard interfaceOrientation != keyboardContext.interfaceOrientation else { return }

    interfaceOrientation = keyboardContext.interfaceOrientation

    let layoutConfig = layoutConfig
    let insets = layoutConfig.buttonInsets

    // Logger.statistics.debug("KeyboardButtonRowItem layoutSubviews() rowHeight: \(layoutConfig.rowHeight), buttonInsets [left: \(insets.left), top: \(insets.top), right: \(insets.right), bottom: \(insets.bottom)]")

    if let topConstraint = topConstraint {
      topConstraint.constant = insets.top
    }

    if let bottomConstraint = bottomConstraint {
      bottomConstraint.constant = -insets.bottom
    }

    if let leadingConstraint = leadingConstraint {
      leadingConstraint.constant = insets.left
    }

    if let trailingConstraint = trailingConstraint {
      trailingConstraint.constant = -insets.right
    }
  }
}
