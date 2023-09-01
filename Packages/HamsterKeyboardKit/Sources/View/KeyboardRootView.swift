//
//  KeyboardRootView.swift
//
//
//  Created by morse on 2023/8/14.
//

import Combine
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

  private var subscriptions = Set<AnyCancellable>()

  /// 工具栏收起时约束
  private var toolbarCollapseConstraints = [NSLayoutConstraint]()

  /// 工具栏展开时约束
  private var toolbarExpandConstraints = [NSLayoutConstraint]()

  /// 工具栏高度约束
  private var toolbarHeightConstraint: NSLayoutConstraint?

  /// 候选文字视图状态
  private var candidateViewState: CandidateWordsView.State

  // MARK: 计算属性

  // MARK: subview

  private lazy var toolbarView: KeyboardToolbarView = {
    let view = KeyboardToolbarView(actionHandler: actionHandler, keyboardContext: keyboardContext, rimeContext: rimeContext)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

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
      rimeContext: rimeContext,
      calloutContext: calloutContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
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
    self.rimeContext = rimeContext
    self.candidateViewState = keyboardContext.candidatesViewState

    super.init(frame: .zero)

    setupView()

    combine()
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

    constructViewHierarchy()
    activateViewConstraints()
  }

  /// 构建视图层次
  func constructViewHierarchy() {
    let enableToolbar = keyboardContext.hamsterConfig?.toolbar?.enableToolbar ?? true
    // TODO: 根据当前键盘类型设置
    let subview = alphabeticKeyboardView
    if enableToolbar {
      addSubview(toolbarView)
      addSubview(subview)
    } else {
      addSubview(subview)
    }
  }

  /// 激活约束
  func activateViewConstraints() {
    // TODO: 根据当前键盘类型设置
    let subview = alphabeticKeyboardView

    let enableToolbar = keyboardContext.hamsterConfig?.toolbar?.enableToolbar ?? true
    if enableToolbar {
      let heightOfToolbar = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfToolbar ?? 55)
      toolbarHeightConstraint = toolbarView.heightAnchor.constraint(equalToConstant: heightOfToolbar)

      toolbarCollapseConstraints = [
        toolbarView.topAnchor.constraint(equalTo: topAnchor),
        toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
        toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),

        subview.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
        subview.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        subview.leadingAnchor.constraint(equalTo: leadingAnchor),
        subview.trailingAnchor.constraint(equalTo: trailingAnchor)
      ]

      toolbarExpandConstraints = [
        toolbarView.topAnchor.constraint(equalTo: topAnchor),
        toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
        toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),
        toolbarView.bottomAnchor.constraint(equalTo: bottomAnchor)
      ]

      toolbarHeightConstraint?.isActive = true
      NSLayoutConstraint.activate(keyboardContext.candidatesViewState.isCollapse() ? toolbarCollapseConstraints : toolbarExpandConstraints)
    } else {
      NSLayoutConstraint.activate([
        subview.topAnchor.constraint(equalTo: topAnchor),
        subview.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        subview.leadingAnchor.constraint(equalTo: leadingAnchor),
        subview.trailingAnchor.constraint(equalTo: trailingAnchor)
      ])
    }
  }

  func combine() {
    // 调节候选栏区域
    if keyboardContext.hamsterConfig?.toolbar?.enableToolbar ?? true {
      keyboardContext.candidatesViewStatePublished
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          setNeedsLayout()
          layoutIfNeeded()
        }
        .store(in: &subscriptions)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let enableToolbar = keyboardContext.hamsterConfig?.toolbar?.enableToolbar ?? true
    guard enableToolbar else { return }

    // 候选文字视图状态如果改变，则需要重新调整布局
    guard candidateViewState != keyboardContext.candidatesViewState else { return }
    Logger.statistics.debug("KeyboardRootView layoutSubviews()")

    candidateViewState = keyboardContext.candidatesViewState

    // TODO: 根据当前键盘类型设置
    let subview = alphabeticKeyboardView
    let heightOfToolbar = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfToolbar ?? 55)
    let subviewHeight = subview.bounds.height

    if candidateViewState.isCollapse() {
      addSubview(subview)
      toolbarHeightConstraint?.constant = heightOfToolbar
      NSLayoutConstraint.deactivate(toolbarExpandConstraints)
      NSLayoutConstraint.activate(toolbarCollapseConstraints)
    } else {
      subview.removeFromSuperview()
      NSLayoutConstraint.deactivate(toolbarCollapseConstraints)
      NSLayoutConstraint.activate(toolbarExpandConstraints)
      toolbarHeightConstraint?.constant = subviewHeight + heightOfToolbar
    }
  }
}
