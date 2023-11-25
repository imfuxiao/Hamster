//
//  StanderSystemKeyboard.swift
//
//
//  Created by morse on 2023/8/10.
//

import HamsterKit
import HamsterUIKit
import OSLog
import UIKit

/**
 标准系统键盘
 */
public class StanderSystemKeyboard: KeyboardTouchView {
  // MARK: - Properties

  private let keyboardLayoutProvider: KeyboardLayoutProvider
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private var actionCalloutContext: ActionCalloutContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  /// TODO: 触摸管理视图
  /// 统一手势处理
  // private let touchView = KeyboardTouchView()

  /// 缓存所有按键视图
  private var keyboardRows: [[KeyboardButton]] = []
  /// 静态视图约束，视图创建完毕后不在发生变化
  private var staticConstraints: [NSLayoutConstraint] = []
  /// 动态视图约束，在键盘方向发生变化后需要更新约束
  private var dynamicConstraints: [NSLayoutConstraint] = []

  // 当前外观
  var userInterfaceStyle: UIUserInterfaceStyle

  // 屏幕方向
  private var interfaceOrientation: InterfaceOrientation

  // 键盘是否浮动
  private var isKeyboardFloating: Bool

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
    self.isKeyboardFloating = keyboardContext.isKeyboardFloating
    self.userInterfaceStyle = keyboardContext.colorScheme

    super.init(frame: .zero)

    setupKeyboardView()
  }

  deinit {
    subviews.forEach { $0.removeFromSuperview() }
  }

  func setupKeyboardView() {
    constructViewHierarchy()
    activateViewConstraints()
    setupAppearance()
  }

  override public func setupAppearance() {
    backgroundColor = .clear
    contentMode = .redraw
  }

  // MARK: Layout

  /// 构建视图层次
  override public func constructViewHierarchy() {
    // addSubview(touchView)

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
        // touchView.addSubview(buttonItem)
        addSubview(buttonItem)
        tempRow.append(buttonItem)
      }

      keyboardRows.append(tempRow)
    }
  }

  /// 按键宽度约束
  /// button: 需要设置约束的按键
  /// inputAnchorButton: 宽度类型为 input 的按键，因为所有 input 类型的按键宽度是一致的
  ///
  /// 注意:
  /// 1. 当行中 .available 类型按键数量等于 1 时，不需要添加宽度约束
  /// 2. 当行中 .available 类型按键数量大于 1 的情况下，需要在行遍历结束后添加等宽约束。即同一行中的所有 .available 类型的宽度相同
  func buttonWidthConstraint(_ button: KeyboardButton, inputAnchorButton: KeyboardButton?) -> NSLayoutConstraint? {
    var constraint: NSLayoutConstraint? = nil
    switch button.item.size.width {
    case .input:
      if let firstInputButton = inputAnchorButton, firstInputButton != button {
        constraint = button.widthAnchor.constraint(equalTo: firstInputButton.widthAnchor)
      }
    case .inputPercentage(let percent):
      let percent = CGFloat.rounded(percent)
      if let firstInputButton = inputAnchorButton {
        constraint = button.widthAnchor.constraint(equalTo: firstInputButton.widthAnchor, multiplier: percent)
      }
    case .percentage(let percent):
      let percent = CGFloat.rounded(percent)
      constraint = button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: percent)
    case .points(let points):
      constraint = button.widthAnchor.constraint(equalToConstant: points)
    default:
      break
    }
    return constraint
  }

  /// 激活视图约束
  override public func activateViewConstraints() {
    // 暂存同一行中 available 宽度类型按键集合
    var availableItems = [KeyboardButton]()

    // 首个 input 宽度类型按钮
    var firstInputButton: KeyboardButton? = nil

    for row in keyboardRows {
      for button in row {
        // 获取首个 input 类型宽度按键
        if firstInputButton == nil && button.item.size.width == .input {
          firstInputButton = button
        }

        // 按键高度约束（高度包含 insets 部分）
        let heightConstant = button.item.size.height
        let buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: heightConstant)
        // TODO: .required 会导致日志打印约束错误，但是改为 .defaultHigh 后，高度约束不起作用，会导致显示的高度有问题
        buttonHeightConstraint.priority = .defaultHigh
        buttonHeightConstraint.identifier = "\(button.row)-\(button.column)-button-height"
        dynamicConstraints.append(buttonHeightConstraint)
        // Logger.statistics.debug("keyboard layoutSubviews(): row: \(button.row), column: \(button.column), rowHeight: \(heightConstant)")

        // 按键宽度约束
        // 注意：.available 类型宽度在行遍历结束后添加
        if let constraint = buttonWidthConstraint(button, inputAnchorButton: firstInputButton) {
          staticConstraints.append(constraint)
        } else {
          // 注意：available 类型按键宽度在 input 类型宽度约束在行遍历后添加
          if button.item.size.width == .available {
            availableItems.append(button)
          }
        }

        // 按键 leading
        if button.column == 0 {
          staticConstraints.append(button.leadingAnchor.constraint(equalTo: leadingAnchor))
        } else {
          let prevItem = row[button.column - 1]
          staticConstraints.append(button.leadingAnchor.constraint(equalTo: prevItem.trailingAnchor))
        }

        // 按键 top
        if button.row == 0 {
          staticConstraints.append(button.topAnchor.constraint(equalTo: topAnchor))
        } else { // 非首行添加相对上一行首个按键的 top 约束
          let prevRowItem = keyboardRows[button.row - 1][0]
          staticConstraints.append(button.topAnchor.constraint(equalTo: prevRowItem.bottomAnchor))
        }

        // 按键 bottom
        // 注意：只有最后一行需要添加
        if button.row + 1 == keyboardRows.endIndex {
          staticConstraints.append(button.bottomAnchor.constraint(equalTo: bottomAnchor))
        }

        // 按键 trailing
        // 注意：只有最后一列需要添加
        if button.column + 1 == row.endIndex {
          staticConstraints.append(button.trailingAnchor.constraint(equalTo: trailingAnchor))
        }
      }

      // 每行循环结束后，平均分配 .available 宽度类型的按键
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

  override public func layoutSubviews() {
    super.layoutSubviews()

    if userInterfaceStyle != keyboardContext.colorScheme {
      userInterfaceStyle = keyboardContext.colorScheme
      subviews.forEach { $0.setNeedsLayout() }
    }

    guard interfaceOrientation != keyboardContext.interfaceOrientation || isKeyboardFloating != keyboardContext.isKeyboardFloating else { return }
    interfaceOrientation = keyboardContext.interfaceOrientation
    isKeyboardFloating = keyboardContext.isKeyboardFloating

    // 是否重新计算自动布局标志
    var resetConstraints = false

    // 约束索引
    var dynamicConstraintsIndex = 0
    for (rowIndex, row) in layout.itemRows.enumerated() {
      for (columnIndex, item) in row.enumerated() {
        let oldItem = keyboardRows[rowIndex][columnIndex].item

        // 检测按键宽度或高度是否发生变化, 如果发生变化，则重新计算自动布局
        resetConstraints = oldItem.size.width != item.size.width || oldItem.size.height != item.size.height

        keyboardRows[rowIndex][columnIndex].item = item

        // 动态变更行高度，如果不存在宽度变化的问题，则只需改变动态高度约束中的高度
        if dynamicConstraintsIndex < dynamicConstraints.count {
          let rowHeight = item.size.height
          // Logger.statistics.debug("Custom keyboard layoutSubviews(): row: \(rowIndex), column: \(columnIndex), rowHeight: \(rowHeight)")
          dynamicConstraints[dynamicConstraintsIndex].constant = rowHeight
        }
        dynamicConstraintsIndex += 1
      }
    }

    if resetConstraints {
      NSLayoutConstraint.deactivate(staticConstraints + dynamicConstraints)
      staticConstraints.removeAll(keepingCapacity: true)
      dynamicConstraints.removeAll(keepingCapacity: true)
      activateViewConstraints()
    }
  }
}
