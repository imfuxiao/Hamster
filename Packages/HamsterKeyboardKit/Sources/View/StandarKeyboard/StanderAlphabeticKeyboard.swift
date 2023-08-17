//
//  StanderAlphabeticKeyboard.swift
//
//
//  Created by morse on 2023/8/10.
//

import Combine
import HamsterKit
import OSLog
import UIKit

/**
 标准字母键盘
 */
public class StanderAlphabeticKeyboard: UIView {
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

  // MARK: - Properties

  private var touchView = KeyboardTouchView()

  private var layout: KeyboardLayout
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let autocompleteToolbarMode: AutocompleteToolbarMode
  private let autocompleteToolbarAction: AutocompleteToolbarAction

  private var actionCalloutContext: ActionCalloutContext
  private var autocompleteContext: AutocompleteContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext

  /// 行中按键宽度类型为 input 的最大数量
  /// 注意：按行统计
  private var maxInputButtonCount = 0

  /// 缓存所有按键视图
  private var keyboardRows: [[KeyboardButton]] = []
  /// 静态视图约束，视图创建完毕后不在发生变化
  private var staticConstraints: [NSLayoutConstraint] = []
  /// 动态视图约束，在键盘方向发生变化后需要更新约束
  private var dynamicConstraints: [NSLayoutConstraint] = []

  // 屏幕方向
  private var interfaceOrientation: InterfaceOrientation

  private var subscriptions = Set<AnyCancellable>()

  // MARK: - 计算属性

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

//  private var actionCalloutStyle: KeyboardActionCalloutStyle {
//    var style = appearance.actionCalloutStyle
//    let insets = layoutConfig.buttonInsets
//    style.callout.buttonInset = CGSize(width: insets.left, height: insets.top)
//    return style
//  }
//
//  private var inputCalloutStyle: KeyboardInputCalloutStyle {
//    var style = appearance.inputCalloutStyle
//    let insets = layoutConfig.buttonInsets
//    style.callout.buttonInset = CGSize(width: insets.left, height: insets.top)
//    return style
//  }

  // MARK: - Initializations

  /**
   Create a system keyboard with custom button views.

   The provided `buttonView` builder will be used to build
   the full button view for every layout item.

   - Parameters:
     - layout: The keyboard layout to use.
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
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    autocompleteContext: AutocompleteContext,
    autocompleteToolbar: AutocompleteToolbarMode,
    autocompleteToolbarAction: @escaping AutocompleteToolbarAction,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?
  ) {
    self.layout = layout
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.autocompleteToolbarMode = autocompleteToolbar
    self.autocompleteToolbarAction = autocompleteToolbarAction
    self.autocompleteContext = autocompleteContext
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext ?? .disabled
    self.actionCalloutContext = calloutContext?.action ?? .disabled
    self.inputCalloutContext = calloutContext?.input ?? .disabled
    self.interfaceOrientation = keyboardContext.interfaceOrientation

    super.init(frame: .zero)

    setupKeyboardView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  /// 构建视图层次
  open func constructViewHierarchy() {
    addSubview(touchView)

    // 添加按键至 View
    for (rowIndex, row) in layout.itemRows.enumerated() {
      var tempRow = [KeyboardButton]()
      var inputCount = 0
      for (itemIndex, item) in row.enumerated() {
        let buttonItem = KeyboardButton(
          row: rowIndex,
          column: itemIndex,
          item: item,
          actionHandler: actionHandler,
          keyboardContext: keyboardContext,
          calloutContext: calloutContext,
          appearance: appearance
        )
        buttonItem.translatesAutoresizingMaskIntoConstraints = false
        // 需要将按键添加至 touchView, 统一处理
        touchView.addSubview(buttonItem)
        tempRow.append(buttonItem)

        if item.size.width == .input {
          inputCount += 1
        }
      }

      maxInputButtonCount = max(maxInputButtonCount, inputCount)
      keyboardRows.append(tempRow)
    }
  }

  /// 激活视图约束
  open func activateViewConstraints() {
    touchView.translatesAutoresizingMaskIntoConstraints = false
    staticConstraints.append(contentsOf: [
      touchView.topAnchor.constraint(equalTo: topAnchor),
      touchView.bottomAnchor.constraint(equalTo: bottomAnchor),
      touchView.leadingAnchor.constraint(equalTo: leadingAnchor),
      touchView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    // 暂存行中 available 类型按键集合
    var availableItems = [KeyboardButton]()
    // 暂存前一个按键，用于按键之间间隙约束
    var prevItem: KeyboardButton?
    // 暂存上一行的按键，用于按键 y 轴约束
    var prevRowItem: KeyboardButton?

    // 根据 keyboardContext 获取当前布局配置
    // 注意：临时变量缓存计算属性的值，避免重复计算
    let layoutConfig = layoutConfig

    // input 宽度类型的宽度约束乘法系数
    let inputMultiplier = CGFloat.rounded(1 / CGFloat(maxInputButtonCount))

    // 为按键不同宽度类型生成约束
    // 注意:
    // 1. 当行中 .available 类型按键数量等于 1 时，不需要添加宽度约束
    // 2. 当行中 .available 类型按键数量大于 1 的情况下，需要在行遍历结束后添加等宽约束。即同一行中的所有 .available 类型的宽度相同
    let inputWidthOfConstraint: (KeyboardButton) -> NSLayoutConstraint? = { [unowned self] in
      switch $0.item.size.width {
      case .available: return nil
      case .input:
        return $0.widthAnchor.constraint(equalTo: touchView.widthAnchor, multiplier: inputMultiplier)
      case .inputPercentage(let percent):
        return $0.widthAnchor.constraint(equalTo: touchView.widthAnchor, multiplier: inputMultiplier * percent)
      case .percentage(let percent):
        return $0.widthAnchor.constraint(equalTo: touchView.widthAnchor, multiplier: percent)
      case .points(let points):
        return $0.widthAnchor.constraint(equalToConstant: points)
      }
    }

    for row in keyboardRows {
      for button in row {
        // 按键高度约束（高度包含 insets 部分）
        let buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: layoutConfig.rowHeight)
        buttonHeightConstraint.identifier = "\(button.row)-\(button.column)-button-height"
        // 注意：必须设置高度约束的优先级，Autolayout 会根据此约束自动更新根视图的高度，否则会与系统自动添加的约束冲突，会有错误日志输出。
        buttonHeightConstraint.priority = .defaultHigh
        dynamicConstraints.append(buttonHeightConstraint)

        // 按键宽度约束
        // 注意：.available 类型宽度在行遍历结束后添加
        if !button.isSpacer, let constraint = inputWidthOfConstraint(button) {
          staticConstraints.append(constraint)
        } else {
          // 注意：available 类型按键宽度在 input 类型宽度约束在行遍历后添加
          availableItems.append(button)
        }

        if button.row == 0 {
          // 首行添加按键相对视图的 top 约束
          staticConstraints.append(button.topAnchor.constraint(equalTo: touchView.topAnchor))
        } else {
          if let prevRowItem = prevRowItem {
            // 其他行添加按键相对上一行按键的 top 约束
            staticConstraints.append(button.topAnchor.constraint(equalTo: prevRowItem.bottomAnchor))
          }

          // 最后一行添加按键相对视图的 bottom 约束
          if button.row + 1 == keyboardRows.endIndex {
            staticConstraints.append(button.bottomAnchor.constraint(lessThanOrEqualTo: touchView.bottomAnchor))
          }
        }

        if button.column == 0 {
          // 首列按键添加相对行的 leading 约束
          staticConstraints.append(button.leadingAnchor.constraint(equalTo: touchView.leadingAnchor))
        } else {
          // 其他列按键添加相对与前一个按键的 leading 约束
          if let prevItem = prevItem {
            staticConstraints.append(button.leadingAnchor.constraint(equalTo: prevItem.trailingAnchor))
          }

          if button.column + 1 == row.endIndex {
            // 最后一列按键添加相对行的 trailing 约束
            staticConstraints.append(button.trailingAnchor.constraint(equalTo: touchView.trailingAnchor))

            // 修改上一行 prevRowItem 变量引用
            prevRowItem = button
          }
        }

        // 修改上一个按键的引用，用于其他按键添加 leading 约束
        prevItem = button
      }

      // 当行中 .available 类型按键数量大于 1 的情况下，添加等宽约束
      if availableItems.count > 1 {
        let firstItem = availableItems.first!
        for item in availableItems.dropFirst() {
          staticConstraints.append(item.widthAnchor.constraint(equalTo: firstItem.widthAnchor))
        }
        availableItems.removeAll()
      }
    }

    NSLayoutConstraint.activate(staticConstraints + dynamicConstraints)
  }

  func setupKeyboardView() {
    backgroundColor = .clear

    constructViewHierarchy()
    activateViewConstraints()

    keyboardContext.$interfaceOrientation
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        if $0 != self.interfaceOrientation {
          Logger.statistics.debug("keyboardContext.$interfaceOrientation is change")
          setNeedsLayout()
        }
      }
      .store(in: &subscriptions)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard interfaceOrientation != keyboardContext.interfaceOrientation else { return }
    interfaceOrientation = keyboardContext.interfaceOrientation

    let rowHeight = layoutConfig.rowHeight

    Logger.statistics.debug("StanderAlphabeticKeyboard layoutSubviews() buttonInsets rowHeight: \(rowHeight)")
    dynamicConstraints.forEach {
      $0.constant = rowHeight
    }
  }
}
