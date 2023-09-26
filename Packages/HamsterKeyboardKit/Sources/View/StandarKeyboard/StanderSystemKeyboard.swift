//
//  StanderSystemKeyboard.swift
//
//
//  Created by morse on 2023/8/10.
//

import Combine
import HamsterKit
import OSLog
import UIKit

/**
 标准系统键盘
 */
public class StanderSystemKeyboard: UIView {
  public typealias KeyboardWidth = CGFloat

  // MARK: - Properties

  private let keyboardLayoutProvider: KeyboardLayoutProvider
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let touchView = KeyboardTouchView()

  private var actionCalloutContext: ActionCalloutContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext
  private var currentKeyboardType: KeyboardType?

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

  private var layout: KeyboardLayout {
    keyboardLayoutProvider.keyboardLayout(for: keyboardContext)
  }

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
     - KeyboardLayoutProvider: The keyboard layout provider.
     - appearance: The keyboard appearance to use.
     - actionHandler: The action handler to use.
     - autocompleteContext: The autocomplete context to use.
     - autocompleteToolbar: The autocomplete toolbar mode to use.
     - keyboardContext: The keyboard context to use.
     - calloutContext: The callout context to use.
   */
  public init(
    keyboardLayoutProvider: KeyboardLayoutProvider,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    rimeContext: RimeContext,
    calloutContext: KeyboardCalloutContext?
  ) {
    self.keyboardLayoutProvider = keyboardLayoutProvider
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext
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
      for (itemIndex, item) in row.enumerated() {
        let buttonItem = KeyboardButton(
          row: rowIndex,
          column: itemIndex,
          item: item,
          actionHandler: actionHandler,
          keyboardContext: keyboardContext,
          rimeContext: rimeContext,
          calloutContext: calloutContext,
          appearance: appearance
        )
        buttonItem.translatesAutoresizingMaskIntoConstraints = false
        // 需要将按键添加至 touchView, 统一处理
        touchView.addSubview(buttonItem)
        tempRow.append(buttonItem)
      }

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
    // let inputMultiplier = CGFloat.rounded(1 / CGFloat(maxInputButtonCount))
//    let inputWidth = layout.inputWidth(for: bounds.width)
    var firstInputButton: KeyboardButton? = nil

    // 为按键不同宽度类型生成约束
    // 注意:
    // 1. 当行中 .available 类型按键数量等于 1 时，不需要添加宽度约束
    // 2. 当行中 .available 类型按键数量大于 1 的情况下，需要在行遍历结束后添加等宽约束。即同一行中的所有 .available 类型的宽度相同
    let inputWidthOfConstraint = { [unowned self] (_ button: KeyboardButton) -> NSLayoutConstraint? in
      var constraint: NSLayoutConstraint? = nil
      switch button.item.size.width {
      case .input:
        if let firstInputButton = firstInputButton, firstInputButton != button {
          constraint = button.widthAnchor.constraint(equalTo: firstInputButton.widthAnchor)
        }
      case .inputPercentage(let percent):
        if let firstInputButton = firstInputButton {
          constraint = button.widthAnchor.constraint(equalTo: firstInputButton.widthAnchor, multiplier: percent)
        }
      case .percentage(let percent):
        constraint = button.widthAnchor.constraint(equalTo: touchView.widthAnchor, multiplier: percent)
      case .points(let points):
        constraint = button.widthAnchor.constraint(equalToConstant: points)
      default:
        break
      }
      return constraint
    }

    for row in keyboardRows {
      for button in row {
        if firstInputButton == nil && button.item.size.width == .input {
          firstInputButton = button
        }

        // 按键高度约束（高度包含 insets 部分）
        let buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: layoutConfig.rowHeight)
        buttonHeightConstraint.identifier = "\(button.row)-\(button.column)-button-height"
        // 注意：必须设置高度约束的优先级，Autolayout 会根据此约束自动更新根视图的高度，否则会与系统自动添加的约束冲突，会有错误日志输出。
        buttonHeightConstraint.priority = .defaultHigh
        dynamicConstraints.append(buttonHeightConstraint)

        // 按键宽度约束
        // 注意：.available 类型宽度在行遍历结束后添加
        if let constraint = inputWidthOfConstraint(button) {
          staticConstraints.append(constraint)
        } else {
          // 注意：available 类型按键宽度在 input 类型宽度约束在行遍历后添加
          if button.item.size.width == .available {
            availableItems.append(button)
          }
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
      if let firstItem = availableItems.first {
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

    // 屏幕方向改变调整行高
    keyboardContext.$interfaceOrientation
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        setNeedsUpdateConstraints()
      }
      .store(in: &subscriptions)

    // 键盘类型发生变化重新加载键盘
    keyboardContext.$keyboardType
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        switch $0 {
        case .chinese, .chineseNumeric, .chineseSymbolic, .alphabetic, .numeric, .symbolic:
          Logger.statistics.debug("keyboardContext.keyboardType is change")
          setNeedsLayout()
        default:
          return
        }
      }
      .store(in: &subscriptions)
  }

  override public func updateConstraints() {
    super.updateConstraints()

    guard interfaceOrientation != keyboardContext.interfaceOrientation else { return }
    interfaceOrientation = keyboardContext.interfaceOrientation
    let rowHeight = layoutConfig.rowHeight
    Logger.statistics.debug("StanderAlphabeticKeyboard layoutSubviews() buttonInsets rowHeight: \(rowHeight)")
    dynamicConstraints.forEach {
      $0.constant = rowHeight
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    if currentKeyboardType != keyboardContext.keyboardType, keyboardContext.keyboardType.needLayoutSubviews {
      currentKeyboardType = keyboardContext.keyboardType

      touchView.subviews.forEach { $0.removeFromSuperview() }
      touchView.removeFromSuperview()

      self.keyboardRows.removeAll(keepingCapacity: true)
      self.staticConstraints.removeAll(keepingCapacity: true)
      self.dynamicConstraints.removeAll(keepingCapacity: true)

      constructViewHierarchy()
      activateViewConstraints()
      return
    }
  }
}
