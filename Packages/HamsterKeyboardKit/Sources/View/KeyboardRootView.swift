//
//  KeyboardRootView.swift
//
//
//  Created by morse on 2023/8/14.
//

import Combine
import HamsterKit
import HamsterUIKit
import OSLog
import UIKit

/**
 键盘根视图
 */
class KeyboardRootView: NibLessView {
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

  private var subscriptions = Set<AnyCancellable>()

  /// 工具栏收起时约束
  private var toolbarCollapseConstraints = [NSLayoutConstraint]()

  /// 工具栏展开时约束
  private var toolbarExpandConstraints = [NSLayoutConstraint]()

  /// 工具栏高度约束
  private var toolbarHeightConstraint: NSLayoutConstraint?

  /// 候选文字视图状态
  private var candidateViewState: CandidateWordsView.State

  // MARK: - 计算属性

  // MARK: - subview

  /// 工具栏
  private lazy var toolbarView: KeyboardToolbarView = {
    let view = KeyboardToolbarView(actionHandler: actionHandler, keyboardContext: keyboardContext, rimeContext: rimeContext)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

//  /// 键盘容器视图
//  private lazy var keyboardContainerView: UIView = {
//    let view = UIView(frame: .zero)
//    view.translatesAutoresizingMaskIntoConstraints = false
//    view.backgroundColor = .clear
//    return view
//  }()

  /// 26键键盘，包含默认中文26键及英文26键
  private lazy var alphabeticKeyboardView: UIView = {
    let view = StanderSystemKeyboard(
      keyboardLayoutProvider: keyboardLayoutProvider,
      appearance: appearance,
      actionHandler: actionHandler,
      autocompleteContext: autocompleteContext,
      keyboardContext: keyboardContext,
      rimeContext: rimeContext,
      calloutContext: calloutContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 中文九宫格键盘
  private lazy var chineseNineGridKeyboardView: UIView = {
    let view = ChineseNineGridKeyboard(
      actionHandler: actionHandler,
      appearance: appearance,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 自定义键盘
  private lazy var customizeKeyboardView: UIView = {
    let view = CustomizeKeyboard(
      keyboardLayoutProvider: keyboardLayoutProvider,
      actionHandler: actionHandler,
      appearance: appearance,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 数字九宫格键盘
  private lazy var numericNineGridKeyboardView: UIView = {
    let view = NumericNineGridKeyboard(
      actionHandler: actionHandler,
      appearance: appearance,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      rimeContext: rimeContext
    )

    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 符号分类键盘
  private lazy var classifySymbolicKeyboardView: ClassifySymbolicKeyboard = {
    let view = ClassifySymbolicKeyboard(actionHandler: actionHandler, layoutProvider: keyboardLayoutProvider, keyboardContext: keyboardContext)
    view.isHidden = true
    return view
  }()

  /// emoji键盘
  private lazy var emojisKeyboardView: UIView = {
    // TODO:
    let view = UIView()
    view.isHidden = true
    view.backgroundColor = .red
    return view
  }()

  /// 主键盘
  private lazy var primaryKeyboardView: UIView = {
    switch keyboardContext.keyboardType {
    case .alphabetic, .symbolic, .numeric, .chinese, .chineseNumeric, .chineseSymbolic:
      return alphabeticKeyboardView
    case .chineseNineGrid:
      return chineseNineGridKeyboardView
    case .custom:
      return customizeKeyboardView
    default:
      return UIView(frame: .zero)
    }
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
    self.candidateViewState = keyboardContext.candidatesViewState

    super.init(frame: .zero)

    setupView()

    combine()
  }

  // MARK: - Layout

  func setupView() {
    // 开启键盘配色
    backgroundColor = keyboardContext.backgroundColor
  }

  override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)

    constructViewHierarchy()
    activateViewConstraints()
  }

  /// 构建视图层次
  override func constructViewHierarchy() {
    if keyboardContext.enableToolbar {
      addSubview(toolbarView)
      addSubview(primaryKeyboardView)
    } else {
      addSubview(primaryKeyboardView)
    }
  }

  /// 激活约束
  override func activateViewConstraints() {
    if keyboardContext.enableToolbar {
      // 工具栏高度约束，可随配置调整高度
      toolbarHeightConstraint = toolbarView.heightAnchor.constraint(equalToConstant: keyboardContext.heightOfToolbar)

      // 工具栏收缩时约束
      toolbarCollapseConstraints = [
        toolbarView.topAnchor.constraint(equalTo: topAnchor),
        toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
        toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),

        primaryKeyboardView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
        primaryKeyboardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        primaryKeyboardView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
        primaryKeyboardView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
      ]

      // 工具栏展开时约束
      toolbarExpandConstraints = [
        toolbarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        toolbarView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
        toolbarView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        toolbarView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
      ]

      toolbarHeightConstraint?.isActive = true
      NSLayoutConstraint.activate(keyboardContext.candidatesViewState.isCollapse() ? toolbarCollapseConstraints : toolbarExpandConstraints)
    } else {
      NSLayoutConstraint.activate([
        primaryKeyboardView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        primaryKeyboardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        primaryKeyboardView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
        primaryKeyboardView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
      ])
    }
  }

  func combine() {
    // 在开启工具栏的状态下，根据候选状态调节候选栏区域大小
    if keyboardContext.enableToolbar {
      keyboardContext.candidatesViewStatePublished
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in
          guard candidateViewState != $0 else { return }
          setNeedsUpdateConstraints()
        }
        .store(in: &subscriptions)
    }

    // 键盘类型
//    keyboardContext.$keyboardType
//      .receive(on: DispatchQueue.main)
//      .sink { [unowned self] in
//        switch $0 {
//        case .classifySymbolic:
//          // TODO: 动画代码重构
//          classifySymbolicKeyboardView.isHidden = false
//          classifySymbolicKeyboardView.frame = classifySymbolicKeyboardView.frame.offsetBy(dx: 0, dy: -frame.height)
//          UIView.animate(withDuration: 0.3, delay: .zero, options: .curveEaseInOut) { [unowned self] in
//            classifySymbolicKeyboardView.frame = classifySymbolicKeyboardView.frame.offsetBy(dx: 0, dy: frame.height)
//          }
//        case .numericNineGrid:
//          numericNineGridKeyboardView.isHidden = false
//        case .emojis:
//          emojisKeyboardView.isHidden = false
//        case .alphabetic, .chinese, .chineseNineGrid, .custom:
//          classifySymbolicKeyboardView.isHidden = true
//          numericNineGridKeyboardView.isHidden = true
//          emojisKeyboardView.isHidden = true
//          keyboardContainerView.subviews.forEach { $0.removeFromSuperview() }
//          let keyboardView = keyboardView
//          keyboardContainerView.addSubview(keyboardView)
//          NSLayoutConstraint.activate([
//            keyboardView.topAnchor.constraint(equalTo: keyboardContainerView.topAnchor),
//            keyboardView.bottomAnchor.constraint(equalTo: keyboardContainerView.bottomAnchor),
//            keyboardView.leadingAnchor.constraint(equalTo: keyboardContainerView.leadingAnchor),
//            keyboardView.trailingAnchor.constraint(equalTo: keyboardContainerView.trailingAnchor)
//          ])
//        default:
//          break
//        }
//      }
//      .store(in: &subscriptions)
  }

  override func updateConstraints() {
    super.updateConstraints()

    // 检测候选栏状态是否发生变化
    guard self.candidateViewState != keyboardContext.candidatesViewState else { return }
    self.candidateViewState = keyboardContext.candidatesViewState
    if candidateViewState.isCollapse() {
      toolbarHeightConstraint?.constant = keyboardContext.heightOfToolbar
      NSLayoutConstraint.deactivate(toolbarExpandConstraints)
      NSLayoutConstraint.activate(toolbarCollapseConstraints)
    } else {
      NSLayoutConstraint.deactivate(toolbarCollapseConstraints)
      NSLayoutConstraint.activate(toolbarExpandConstraints)
      toolbarHeightConstraint?.constant = primaryKeyboardView.bounds.height + keyboardContext.heightOfToolbar
    }
  }
}
