//
//  KeyboardRootView.swift
//
//
//  Created by morse on 2023/8/14.
//

import HamsterKit
import OSLog
import UIKit

/**
 键盘根视图
 */
class KeyboardRootView: UIView {
  public enum AutocompleteToolbarMode {
    /// Show the autocomplete toolbar if the keyboard context prefers it.
    ///
    /// 如果键盘上下文偏好自动完成工具栏，则显示该工具栏。
    case automatic

    /// Never show the autocomplete toolbar.
    ///
    /// 绝不显示自动完成工具栏。
    case none
  }

  public typealias AutocompleteToolbarAction = (AutocompleteSuggestion) -> Void
  public typealias KeyboardWidth = CGFloat
  public typealias KeyboardItemWidth = CGFloat

  // MARK: - Properties

  private let keyboardLayoutProvider: KeyboardLayoutProvider
  private let layout: KeyboardLayout
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let autocompleteToolbarMode: AutocompleteToolbarMode
  private let autocompleteToolbarAction: AutocompleteToolbarAction = { _ in }
  private let layoutConfig: KeyboardLayoutConfiguration

  private var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = appearance.actionCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = CGSize(width: insets.left, height: insets.top)
    return style
  }

  private var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = appearance.inputCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = CGSize(width: insets.left, height: insets.top)
    return style
  }

  private var actionCalloutContext: ActionCalloutContext
  private var autocompleteContext: AutocompleteContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext

  // MARK: 计算属性

  // MARK: subview

  /// 字母键盘
  private lazy var alphabeticKeyboardView: UIView = {
    let view = StanderAlphabeticKeyboard(
      layout: layout,
      appearance: appearance,
      actionHandler: actionHandler,
      autocompleteContext: autocompleteContext,
      autocompleteToolbar: .automatic,
      autocompleteToolbarAction: { _ in },
      keyboardContext: keyboardContext,
      calloutContext: calloutContext
    )
    return view
  }()

  /// 数字键盘
  private lazy var numericKeyboardView: UIView = {
    let view = UIView()

    // TODO:

    view.backgroundColor = .yellow

    return view
  }()

  /// 符号键盘
  private lazy var symbolicKeyboardView: UIView = {
    let view = UIView()

    // TODO:

    view.backgroundColor = .blue

    return view
  }()

  private lazy var emojisKeyboardView: UIView = {
    let view = UIView()

    // TODO:

    view.backgroundColor = .red

    return view
  }()

  // MARK: - Initializations

  /**
   Create a system keyboard with custom button views.

   The provided `buttonView` builder will be used to build
   the full button view for every layout item.

   - Parameters:
     - keyboardLayoutProvider: The keyboard layout provider to use.
     - appearance: The keyboard appearance to use.
     - actionHandler: The action handler to use.
     - autocompleteContext: The autocomplete context to use.
     - autocompleteToolbar: The autocomplete toolbar mode to use.
     - autocompleteToolbarAction: The action to trigger when tapping an autocomplete suggestion.
     - keyboardContext: The keyboard context to use.
     - calloutContext: The callout context to use.
     - width: The keyboard width.
   */
  public init(
    keyboardLayoutProvider: KeyboardLayoutProvider,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    autocompleteContext: AutocompleteContext,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?
  ) {
    self.keyboardLayoutProvider = keyboardLayoutProvider
    self.layout = keyboardLayoutProvider.keyboardLayout(for: keyboardContext)
    self.layoutConfig = .standard(for: keyboardContext)
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.autocompleteToolbarMode = .automatic
    self.autocompleteContext = autocompleteContext
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext ?? .disabled
    self.actionCalloutContext = calloutContext?.action ?? .disabled
    self.inputCalloutContext = calloutContext?.input ?? .disabled

    super.init(frame: .zero)

    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func setupView() {
    backgroundColor = .clear

    subviews.forEach { $0.removeFromSuperview() }

    // TODO: 添加工具栏

    // TODO: 根据当前键盘类型设置
    let subview = alphabeticKeyboardView

    addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: topAnchor),
      subview.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
      subview.leadingAnchor.constraint(equalTo: leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
}
