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

  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let autocompleteToolbarMode: AutocompleteToolbarMode
  private let autocompleteToolbarAction: AutocompleteToolbarAction = { _ in }
  private let layoutConfig: KeyboardLayoutConfiguration

  private var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = appearance.actionCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = insets
    return style
  }

  private var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = appearance.inputCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = insets
    return style
  }

  private var actionCalloutContext: ActionCalloutContext
  private var autocompleteContext: AutocompleteContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  // MARK: 计算属性

  // MARK: subview

  private lazy var toolbarView: KeyboardToolbarView = {
    let view = KeyboardToolbarView(actionHandler: actionHandler, keyboardContext: keyboardContext, rimeContext: rimeContext)
    return view
  }()

  /// 字母键盘
  private lazy var alphabeticKeyboardView: UIView = {
    let view = StanderAlphabeticKeyboard(
      keyboardLayoutProvider: keyboardLayoutProvider,
      appearance: appearance,
      actionHandler: actionHandler,
      autocompleteContext: autocompleteContext,
      autocompleteToolbar: .automatic,
      autocompleteToolbarAction: { _ in },
      keyboardContext: keyboardContext,
      rimeContext: rimeContext,
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
    calloutContext: KeyboardCalloutContext?,
    rimeContext: RimeContext
  ) {
    self.keyboardLayoutProvider = keyboardLayoutProvider

    self.layoutConfig = .standard(for: keyboardContext)
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.autocompleteToolbarMode = .automatic
    self.autocompleteContext = autocompleteContext
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext ?? .disabled
    self.actionCalloutContext = calloutContext?.action ?? .disabled
    self.inputCalloutContext = calloutContext?.input ?? .disabled
    self.rimeContext = rimeContext

    super.init(frame: .zero)

    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func setupView() {
    // 开启键盘配色
    if keyboardContext.hamsterConfig?.Keyboard?.enableColorSchema ?? false, let keyboardColor = keyboardContext.hamsterKeyboardColor {
      backgroundColor = keyboardColor.backColor
    } else {
      backgroundColor = .clear
    }

    subviews.forEach { $0.removeFromSuperview() }

    // TODO: 添加工具栏

    // TODO: 根据当前键盘类型设置
    let subview = alphabeticKeyboardView

    addSubview(toolbarView)
    addSubview(subview)
    toolbarView.translatesAutoresizingMaskIntoConstraints = false
    subview.translatesAutoresizingMaskIntoConstraints = false

    let enableToolbar = keyboardContext.hamsterConfig?.toolbar?.enableToolbar ?? true
    let heightOfToolbar = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfToolbar ?? 55)

    if enableToolbar {
      NSLayoutConstraint.activate([
        toolbarView.topAnchor.constraint(equalTo: topAnchor),

        // TODO: 动态调整工具栏高度
        toolbarView.heightAnchor.constraint(equalToConstant: heightOfToolbar),
        toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
        toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),
        subview.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),

        subview.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        subview.leadingAnchor.constraint(equalTo: leadingAnchor),
        subview.trailingAnchor.constraint(equalTo: trailingAnchor)
      ])
    } else {
      NSLayoutConstraint.activate([
        subview.topAnchor.constraint(equalTo: topAnchor),
        subview.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        subview.leadingAnchor.constraint(equalTo: leadingAnchor),
        subview.trailingAnchor.constraint(equalTo: trailingAnchor)
      ])
    }
  }
}
