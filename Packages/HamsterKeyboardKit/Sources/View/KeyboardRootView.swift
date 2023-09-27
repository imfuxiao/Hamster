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

  /// 非主键盘之外的临时键盘，如：数字九宫格/分类符号键盘等
  private var tempKeyboardView: UIView? = nil

  /// 非主键盘的临时键盘Cache
  private var tempKeyboardViewCache: [KeyboardType: UIView] = [:]

  // MARK: - 计算属性

  // MARK: - subview

  /// 工具栏
  private lazy var toolbarView: KeyboardToolbarView = {
    let view = KeyboardToolbarView(actionHandler: actionHandler, keyboardContext: keyboardContext, rimeContext: rimeContext)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 26键键盘，包含默认中文26键及英文26键
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

  /// 自定义键盘
  private var customizeKeyboardView: CustomizeKeyboard {
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
  }

  /// 主键盘
  private lazy var primaryKeyboardView: UIView = {
    switch keyboardContext.selectKeyboard {
    case .chinese:
      return standerSystemKeyboard
    case .chineseNineGrid:
      return chineseNineGridKeyboardView
    case .custom:
      return customizeKeyboardView
    default:
      return UIView(frame: .zero)
    }
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
    return view
  }()

  /// 符号分类键盘
  private lazy var classifySymbolicKeyboardView: ClassifySymbolicKeyboard = {
    let view = ClassifySymbolicKeyboard(actionHandler: actionHandler, layoutProvider: keyboardLayoutProvider, keyboardContext: keyboardContext)
    return view
  }()

  /// emoji键盘
  private lazy var emojisKeyboardView: UIView = {
    // TODO:
    let view = UIView()
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
        primaryKeyboardView.bottomAnchor.constraint(equalTo: bottomAnchor),
        primaryKeyboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
        primaryKeyboardView.trailingAnchor.constraint(equalTo: trailingAnchor)
      ]

      // 工具栏展开时约束
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
        primaryKeyboardView.topAnchor.constraint(equalTo: topAnchor),
        primaryKeyboardView.bottomAnchor.constraint(equalTo: bottomAnchor),
        primaryKeyboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
        primaryKeyboardView.trailingAnchor.constraint(equalTo: trailingAnchor)
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

    // 跟踪键盘类型变化
    keyboardContext.$keyboardType
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        Logger.statistics.debug("KeyboardRootView keyboardType combine: \($0.yamlString)")
        // 判断当前键盘类型是否为 primaryKeyboard
        guard $0 != keyboardContext.selectKeyboard else {
          // 显示主键盘，并隐藏非主键盘
          primaryKeyboardView.isHidden = false
          if let view = self.tempKeyboardView {
            self.tempKeyboardView = nil
            view.layer.zPosition = -1
            view.frame = view.frame.offsetBy(dx: 0, dy: -self.frame.height)
          }
          return
        }

        // 先将之前的临时键盘隐藏
        if let view = self.tempKeyboardView {
          view.frame = view.frame.offsetBy(dx: 0, dy: -self.frame.height)
          self.tempKeyboardView = nil
        }

        // 从 cache 中获取键盘
        if let tempKeyboardView = tempKeyboardViewCache[$0] {
          // 隐藏主键盘并显示非主键盘
          primaryKeyboardView.isHidden = true
          tempKeyboardView.frame = tempKeyboardView.frame.offsetBy(dx: 0, dy: self.frame.height)
          tempKeyboardView.layer.zPosition = 999
          self.tempKeyboardView = tempKeyboardView

          return
        }

        // 生成临时键盘
        var tempKeyboardView: UIView? = nil
        switch $0 {
        case .numericNineGrid:
          tempKeyboardView = numericNineGridKeyboardView
          tempKeyboardView!.frame = primaryKeyboardView.frame.offsetBy(dx: 0, dy: -self.frame.height)
        case .classifySymbolic:
          tempKeyboardView = classifySymbolicKeyboardView
          tempKeyboardView!.frame = self.frame.offsetBy(dx: 0, dy: -self.frame.height)
        case .emojis:
          tempKeyboardView = emojisKeyboardView
          tempKeyboardView!.frame = self.frame.offsetBy(dx: 0, dy: -self.frame.height)
        case .alphabetic, .numeric, .symbolic, .chinese, .chineseNumeric, .chineseSymbolic:
          tempKeyboardView = standerSystemKeyboard
          tempKeyboardView!.frame = primaryKeyboardView.frame.offsetBy(dx: 0, dy: -self.frame.height)
        case .chineseNineGrid:
          tempKeyboardView = chineseNineGridKeyboardView
          tempKeyboardView!.frame = primaryKeyboardView.frame.offsetBy(dx: 0, dy: -self.frame.height)
        case .custom:
          tempKeyboardView = customizeKeyboardView
          tempKeyboardView!.frame = primaryKeyboardView.frame.offsetBy(dx: 0, dy: -self.frame.height)
        default:
          // 注意：非临时键盘类型外的类型直接 return
          Logger.statistics.error("keyboadType: \($0.yamlString) not match tempKeyboardType")
        }

        if let tempKeyboardView = tempKeyboardView {
          // 隐藏主键盘并显示临时键盘
          primaryKeyboardView.isHidden = true
          tempKeyboardViewCache[$0] = tempKeyboardView
          tempKeyboardView.translatesAutoresizingMaskIntoConstraints = true
          addSubview(tempKeyboardView)
          tempKeyboardView.frame = tempKeyboardView.frame.offsetBy(dx: 0, dy: self.frame.height)
          tempKeyboardView.layer.zPosition = 999
          self.tempKeyboardView = tempKeyboardView
        }
      }
      .store(in: &subscriptions)
  }

  override func updateConstraints() {
    super.updateConstraints()

    // 检测候选栏状态是否发生变化
    guard self.candidateViewState != keyboardContext.candidatesViewState else { return }
    self.candidateViewState = keyboardContext.candidatesViewState
    if candidateViewState.isCollapse() {
      toolbarHeightConstraint?.constant = keyboardContext.heightOfToolbar
      primaryKeyboardView.isHidden = false
      NSLayoutConstraint.deactivate(toolbarExpandConstraints)
      NSLayoutConstraint.activate(toolbarCollapseConstraints)
    } else {
      primaryKeyboardView.isHidden = true
      NSLayoutConstraint.deactivate(toolbarCollapseConstraints)
      NSLayoutConstraint.activate(toolbarExpandConstraints)
      toolbarHeightConstraint?.constant = primaryKeyboardView.bounds.height + keyboardContext.heightOfToolbar
    }
  }
}
