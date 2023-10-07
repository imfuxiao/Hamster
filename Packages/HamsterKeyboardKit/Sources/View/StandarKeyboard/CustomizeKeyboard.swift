//
//  CustomizeKeyboard.swift
//
//
//  Created by morse on 2023/9/18.
//

import Combine
import HamsterUIKit
import UIKit

/// 自定义布局键盘
class CustomizeKeyboard: NibLessView {
  // MARK: - Properties

  private let keyboardLayoutProvider: KeyboardLayoutProvider
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private var keyboardContext: KeyboardContext
  private var calloutContext: KeyboardCalloutContext
  private var rimeContext: RimeContext

  // combine
  private var subscriptions = Set<AnyCancellable>()

  /// 缓存所有按键视图
  private var keyboardRows: [[KeyboardButton]] = []

  /// 静态视图约束，视图创建完毕后不在发生变化
  private var staticConstraints: [NSLayoutConstraint] = []

  /// 动态视图约束，在键盘方向发生变化后需要更新约束
  private var dynamicConstraints: [NSLayoutConstraint] = []

  // MARK: - 计算属性

  private var layout: KeyboardLayout {
    keyboardLayoutProvider.keyboardLayout(for: keyboardContext)
  }

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Initialization

  public init(
    keyboardLayoutProvider: KeyboardLayoutProvider,
    actionHandler: KeyboardActionHandler,
    appearance: KeyboardAppearance,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext,
    rimeContext: RimeContext
  ) {
    self.keyboardLayoutProvider = keyboardLayoutProvider
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)
  }

  // MARK: - Layout

  override func didMoveToWindow() {
    super.didMoveToWindow()

    setupKeyboardView()
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
  }

  override func constructViewHierarchy() {
    // 添加按键
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
        addSubview(buttonItem)
        tempRow.append(buttonItem)
      }
      keyboardRows.append(tempRow)
    }
  }

  override func activateViewConstraints() {
    // 暂存中间部分按键，用于平分剩余宽度
    var availableItems = [KeyboardButton]()

    // 暂存前一个按键，用于按键之间的约束
    var prevItem: KeyboardButton?

    // 首个宽度类型为 Input 的按键, 用来约束 input/inputPercentage 类型的宽度
    var firstInputButton: KeyboardButton?

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
        constraint = button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: percent)
      case .points(let points):
        constraint = button.widthAnchor.constraint(equalToConstant: points)
      default:
        break
      }
      return constraint
    }

    for row in keyboardRows {
      for button in row {
        // 获取首个 input 类型宽度按键
        if firstInputButton == nil, button.item.size.width == .input {
          firstInputButton = button
        }

        // 按键高度约束（高度包含 insets 部分）
        if button.column == 0 {
          let heightConstant = button.item.size.height
          let buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: heightConstant)
          // buttonHeightConstraint.priority = button.row + 1 == row.endIndex ? .defaultHigh : .required
          buttonHeightConstraint.priority = .defaultHigh
          buttonHeightConstraint.identifier = "\(button.row)-\(button.column)-button-height"
          dynamicConstraints.append(buttonHeightConstraint)
        } else {
          staticConstraints.append(button.heightAnchor.constraint(equalTo: row[0].heightAnchor, multiplier: 1.0))
        }

        // 按键宽度约束
        // 注意：.available 类型宽度在行遍历结束后添加
        if let constraint = inputWidthOfConstraint(button) {
          staticConstraints.append(constraint)
        } else {
          // 注意：available 类型宽度在每行遍历结束后在添加，用来做行剩余宽度平均分配
          if button.item.size.width == .available {
            availableItems.append(button)
          }
        }

        // 按键 leading
        if button.column == 0 {
          staticConstraints.append(button.leadingAnchor.constraint(equalTo: leadingAnchor))
        } else if let prevItem = prevItem {
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

        // 修改上一个按键的引用，用于其他按键添加 leading 约束
        prevItem = button
      }

      /// 平均分配每行中宽度类型为 available 按键的宽度
      if let firstItem = availableItems.first {
        for item in availableItems.dropFirst() {
          staticConstraints.append(item.widthAnchor.constraint(equalTo: firstItem.widthAnchor))
        }
        availableItems.removeAll()
      }
    }
    NSLayoutConstraint.activate(staticConstraints + dynamicConstraints)
  }
}
