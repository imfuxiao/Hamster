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
  public typealias KeyboardWidth = CGFloat
  public typealias KeyboardItemWidth = CGFloat

  // MARK: - Properties

  private let keyboardLayoutProvider: KeyboardLayoutProvider
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let layoutConfig: KeyboardLayoutConfiguration
  private var actionCalloutContext: ActionCalloutContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  private var subscriptions = Set<AnyCancellable>()

  /// 当前键盘类型
  private var currentKeyboardType: KeyboardType

  /// 当前屏幕方向
  private var interfaceOrientation: InterfaceOrientation

  /// 当前界面样式
  private var userInterfaceStyle: UIUserInterfaceStyle

  /// 键盘是否浮动
  private var isKeyboardFloating: Bool

  /// 工具栏收起时约束
  private var toolbarCollapseDynamicConstraints = [NSLayoutConstraint]()

  /// 工具栏展开时约束
  private var toolbarExpandDynamicConstraints = [NSLayoutConstraint]()

  /// 工具栏高度约束
  private var toolbarHeightConstraint: NSLayoutConstraint?

  /// 候选文字视图状态
  private var candidateViewState: CandidateBarView.State

  /// 非主键盘的临时键盘Cache
  // private var tempKeyboardViewCache: [KeyboardType: UIView] = [:]

  // MARK: - 计算属性

//  private var actionCalloutStyle: KeyboardActionCalloutStyle {
//    var style = appearance.actionCalloutStyle
//    let insets = layoutConfig.buttonInsets
//    style.callout.buttonInset = insets
//    return style
//  }

//  private var inputCalloutStyle: KeyboardInputCalloutStyle {
//    var style = appearance.inputCalloutStyle
//    let insets = layoutConfig.buttonInsets
//    style.callout.buttonInset = insets
//    return style
//  }

  // MARK: - subview

  /// 26键键盘，包含默认中文26键及英文26键
  /// 注意：计算属性， 在 primaryKeyboardView 闭包中按需创建
  private var standerSystemKeyboard: StanderSystemKeyboard {
    let view = StanderSystemKeyboard(
      keyboardLayoutProvider: keyboardLayoutProvider,
      appearance: appearance,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      rimeContext: rimeContext,
      calloutContext: calloutContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 中文九宫格键盘
  /// 注意：计算属性， 在 primaryKeyboardView 闭包中按需创建
  private var chineseNineGridKeyboardView: ChineseNineGridKeyboard {
    let view = ChineseNineGridKeyboard(
      keyboardLayoutProvider: keyboardLayoutProvider,
      actionHandler: actionHandler,
      appearance: appearance,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 数字九宫格键盘
  /// 注意：计算属性
  private var numericNineGridKeyboardView: UIView {
    let view = NumericNineGridKeyboard(
      actionHandler: actionHandler,
      appearance: appearance,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 符号分类键盘
  /// 注意：计算属性
  private var classifySymbolicKeyboardView: ClassifySymbolicKeyboard {
    let view = ClassifySymbolicKeyboard(
      actionHandler: actionHandler,
      appearance: appearance,
      layoutProvider: keyboardLayoutProvider,
      keyboardContext: keyboardContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// emoji键盘
  /// 注意：计算属性
  private var emojisKeyboardView: UIView {
    // TODO:
    let view = UIView()
    view.backgroundColor = .red
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 工具栏
  private lazy var toolbarView: UIView = {
    let view = KeyboardToolbarView(appearance: appearance, actionHandler: actionHandler, keyboardContext: keyboardContext, rimeContext: rimeContext)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 主键盘
  private lazy var primaryKeyboardView: UIView = {
    if let view = chooseKeyboard(keyboardType: keyboardContext.keyboardType) {
      return view
    }
    return standerSystemKeyboard
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
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?,
    rimeContext: RimeContext
  ) {
    self.keyboardLayoutProvider = keyboardLayoutProvider
    self.layoutConfig = .standard(for: keyboardContext)
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext ?? .disabled
    self.actionCalloutContext = calloutContext?.action ?? .disabled
    self.inputCalloutContext = calloutContext?.input ?? .disabled
    self.rimeContext = rimeContext
    self.candidateViewState = keyboardContext.candidatesViewState
    self.currentKeyboardType = keyboardContext.keyboardType
    self.interfaceOrientation = keyboardContext.interfaceOrientation
    self.isKeyboardFloating = keyboardContext.isKeyboardFloating
    self.userInterfaceStyle = keyboardContext.colorScheme

    super.init(frame: .zero)

    // Test
//    let view = UIView()
//    view.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
//    view.backgroundColor = .yellow
//    addSubview(view)

    constructViewHierarchy()
    activateViewConstraints()
    setupAppearance()

    combine()
  }

  deinit {
    subviews.forEach { $0.removeFromSuperview() }
  }

  override func setupAppearance() {
    backgroundColor = appearance.backgroundStyle.backgroundColor
    contentMode = .redraw
  }

  // MARK: - Layout

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

      // 工具栏静态约束
      let toolbarStaticConstraint = createToolbarStaticConstraints()

      // 工具栏收缩时动态约束
      toolbarCollapseDynamicConstraints = createToolbarCollapseDynamicConstraints()

      // 工具栏展开时动态约束
      toolbarExpandDynamicConstraints = createToolbarExpandDynamicConstraints()

      NSLayoutConstraint.activate(toolbarStaticConstraint + toolbarCollapseDynamicConstraints + [toolbarHeightConstraint!])
    } else {
      NSLayoutConstraint.activate(createNoToolbarConstraints())
    }
  }

  /// 工具栏静态约束（不会发生变动）
  func createToolbarStaticConstraints() -> [NSLayoutConstraint] {
    return [
      toolbarView.topAnchor.constraint(equalTo: topAnchor),
      toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
      toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ]
  }

  /// 工具栏展开时动态约束
  func createToolbarExpandDynamicConstraints() -> [NSLayoutConstraint] {
    return [
      toolbarView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ]
  }

  /// 工具栏收缩时动态约束
  func createToolbarCollapseDynamicConstraints() -> [NSLayoutConstraint] {
    return [
      primaryKeyboardView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
      primaryKeyboardView.bottomAnchor.constraint(equalTo: bottomAnchor),
      primaryKeyboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
      primaryKeyboardView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ]
  }

  /// 无工具栏时约束
  func createNoToolbarConstraints() -> [NSLayoutConstraint] {
    return [
      primaryKeyboardView.topAnchor.constraint(equalTo: topAnchor),
      primaryKeyboardView.bottomAnchor.constraint(equalTo: bottomAnchor),
      primaryKeyboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
      primaryKeyboardView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ]
  }

  func combine() {
    // 在开启工具栏的状态下，根据候选状态调节候选栏区域大小
    if keyboardContext.enableToolbar {
      keyboardContext.$candidatesViewState
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          guard candidateViewState != $0 else { return }
          setNeedsLayout()
        }
        .store(in: &subscriptions)
    }

    // 跟踪 UIUserInterfaceStyle 变化
    keyboardContext.$traitCollection
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard userInterfaceStyle != $0.userInterfaceStyle else { return }
        userInterfaceStyle = $0.userInterfaceStyle
        setupAppearance()
        if keyboardContext.enableToolbar {
          toolbarView.setNeedsLayout()
        }
        primaryKeyboardView.setNeedsLayout()
      }
      .store(in: &subscriptions)

    // 屏幕方向改变调整按键高度及按键内距
    keyboardContext.$interfaceOrientation
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard $0 != self.interfaceOrientation else { return }
        self.interfaceOrientation = $0
        self.primaryKeyboardView.setNeedsLayout()
      }
      .store(in: &subscriptions)

    // iPad 浮动模式开启
    keyboardContext.$isKeyboardFloating
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard self.isKeyboardFloating != $0 else { return }
        self.isKeyboardFloating = $0
        self.primaryKeyboardView.setNeedsLayout()
      }
      .store(in: &subscriptions)

    // 跟踪键盘类型变化
    keyboardContext.keyboardTypePublished
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard $0 != currentKeyboardType else { return }
        currentKeyboardType = $0

        Logger.statistics.debug("KeyboardRootView keyboardType combine: \($0.yamlString)")

        guard let keyboardView = chooseKeyboard(keyboardType: $0) else {
          Logger.statistics.error("\($0.yamlString) cannot find keyboardView.")
          return
        }

        if keyboardContext.enableToolbar {
          // NSLayoutConstraint.deactivate(toolbarCollapseDynamicConstraints)
          toolbarCollapseDynamicConstraints.removeAll(keepingCapacity: true)
          toolbarExpandDynamicConstraints.removeAll(keepingCapacity: true)

          primaryKeyboardView.subviews.forEach { $0.removeFromSuperview() }
          primaryKeyboardView.removeFromSuperview()

          primaryKeyboardView = keyboardView
          addSubview(primaryKeyboardView)

          // 工具栏收缩时约束
          toolbarCollapseDynamicConstraints = createToolbarCollapseDynamicConstraints()

          // 工具栏展开时约束
          toolbarExpandDynamicConstraints = createToolbarExpandDynamicConstraints()

          NSLayoutConstraint.activate(toolbarCollapseDynamicConstraints)
        } else {
          NSLayoutConstraint.deactivate(constraints)
          primaryKeyboardView.removeFromSuperview()
          primaryKeyboardView = keyboardView
          addSubview(primaryKeyboardView)
          NSLayoutConstraint.activate(createNoToolbarConstraints())
        }
      }
      .store(in: &subscriptions)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // Logger.statistics.debug("KeyboardRootView: layoutSubviews()")

    // 检测候选栏状态是否发生变化
    guard candidateViewState != keyboardContext.candidatesViewState else { return }
    candidateViewState = keyboardContext.candidatesViewState

    // 候选栏收起
    if candidateViewState.isCollapse() {
      // 键盘显示
      toolbarHeightConstraint?.constant = keyboardContext.heightOfToolbar
      addSubview(primaryKeyboardView)
      NSLayoutConstraint.deactivate(toolbarExpandDynamicConstraints)
      NSLayoutConstraint.activate(toolbarCollapseDynamicConstraints)
    } else {
      // 键盘隐藏
      let toolbarHeight = primaryKeyboardView.bounds.height + keyboardContext.heightOfToolbar
      primaryKeyboardView.removeFromSuperview()

      toolbarHeightConstraint?.constant = toolbarHeight
      NSLayoutConstraint.deactivate(toolbarCollapseDynamicConstraints)
      NSLayoutConstraint.activate(toolbarExpandDynamicConstraints)
    }
  }

  /// 根据键盘类型选择键盘
  func chooseKeyboard(keyboardType: KeyboardType) -> UIView? {
//    // 从 cache 中获取键盘
//    if let tempKeyboardView = tempKeyboardViewCache[keyboardType] {
//      return tempKeyboardView
//    }

    // 生成临时键盘
    var tempKeyboardView: UIView? = nil
    switch keyboardType {
    case .numericNineGrid:
      tempKeyboardView = numericNineGridKeyboardView
    case .classifySymbolic:
      tempKeyboardView = classifySymbolicKeyboardView
    case .emojis:
      tempKeyboardView = emojisKeyboardView
    case .alphabetic, .numeric, .symbolic, .chinese, .chineseNumeric, .chineseSymbolic, .custom:
      tempKeyboardView = standerSystemKeyboard
    case .chineseNineGrid:
      tempKeyboardView = chineseNineGridKeyboardView
    default:
      // 注意：非临时键盘类型外的类型直接 return
      Logger.statistics.error("keyboardType: \(keyboardType.yamlString) not match tempKeyboardType")
      return nil
    }

    // 保存 cache
//    tempKeyboardViewCache[keyboardType] = tempKeyboardView
    return tempKeyboardView
  }
}
