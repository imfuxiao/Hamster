//
//  CustomizeKeyboardLayoutProvider.swift
//
//
//  Created by morse on 2023/9/4.
//

import HamsterKit
import OSLog
import UIKit

/// 自定义键盘布局 Provider
open class CustomizeKeyboardLayoutProvider: KeyboardLayoutProvider {
  private unowned let keyboardLayoutProvider: KeyboardLayoutProvider

  /// 自定义键盘
  private let keyboards: [Keyboard]

  init(keyboardLayoutProvider: KeyboardLayoutProvider, keyboards: [Keyboard]) {
    self.keyboardLayoutProvider = keyboardLayoutProvider
    self.keyboards = keyboards
  }

  public func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    // 非自定义键盘返回其他 provider
    guard case .custom(let name, let casing) = context.keyboardType else { return keyboardLayoutProvider.keyboardLayout(for: context) }
    guard var keyboard = keyboards.first(where: { $0.name == name }) else {
      Logger.statistics.error("not found custom keyboard. name: \(name)")
      return KeyboardLayout(itemRows: [])
    }
    let actions = self.actions(keyboard: &keyboard, casing: casing, context: context)
    let items = self.items(for: actions, keyboard: keyboard, context: context)
    return KeyboardLayout(itemRows: items, customKeyboard: keyboard)
  }

  public func register(inputSetProvider: InputSetProvider) {
    // 不需要实现
  }

  /**
   获取自定义键盘 actions
   */
  open func actions(keyboard: inout Keyboard, casing: KeyboardCase, context: KeyboardContext) -> KeyboardActionRows {
    var rows = KeyboardActionRows()
    for (rowIndex, row) in keyboard.rows.enumerated() {
      var actions = KeyboardActions()
      for (keyIndex, var key) in row.keys.enumerated() {
        if key.action.isShiftAction {
          key.action = .shift(currentCasing: casing)
        }
        if case .character(let char) = key.action {
          key.action = .character(casing.isUppercased ? char.uppercased() : char.lowercased())
        }
        if case .characterMargin(let char) = key.action {
          key.action = .characterMargin(casing.isUppercased ? char.uppercased() : char.lowercased())
        }

        /// 将自定义 return 按钮还原为跟随系统环境变化
        if key.action.isPrimaryAction {
          key.action = keyboardReturnAction(for: context)
        }
        keyboard.rows[rowIndex].keys[keyIndex] = key
        actions.append(key.action)
      }
      rows.append(actions)
    }
    return rows
  }

  open func items(for actions: KeyboardActionRows, keyboard: Keyboard, context: KeyboardContext) -> KeyboardLayoutItemRows {
    actions.enumerated().map { row in
      row.element.enumerated().map { action in
        item(for: action.element, row: row.offset, index: action.offset, keyboard: keyboard, context: context)
      }
    }
  }

  open func item(for action: KeyboardAction, row: Int, index: Int, keyboard: Keyboard, context: KeyboardContext) -> KeyboardLayoutItem {
    let size = itemSize(for: action, row: row, index: index, keyboard: keyboard, context: context)
    let insets = itemInsets(for: action, row: row, index: index, keyboard: keyboard, context: context)
    let key = keyboard.rows[row].keys[index]
    let swipes = key.swipe
    return KeyboardLayoutItem(action: action, size: size, insets: insets, swipes: swipes, key: key)
  }

  open func itemSize(for action: KeyboardAction, row: Int, index: Int, keyboard: Keyboard, context: KeyboardContext) -> KeyboardLayoutItemSize {
    let keyboardRow = keyboard.rows[row]
    let key = keyboardRow.keys[index]
    let width = context.interfaceOrientation.isPortrait ? key.width.portrait : key.width.landscape

    /// 行高度优先
    if let height = keyboardRow.rowHeight {
      return KeyboardLayoutItemSize(width: width, height: context.interfaceOrientation.isPortrait ? height.portrait : height.landscape)
    }

    /// 键盘配置全局高度次优先
    if let height = keyboard.rowHeight {
      return KeyboardLayoutItemSize(width: width, height: context.interfaceOrientation.isPortrait ? height.portrait : height.landscape)
    }

    /// 如果都没有配置，则取系统默认高度
    let height = itemSizeHeight(for: action, row: row, index: index, context: context)
    return KeyboardLayoutItemSize(width: width, height: height)
  }

  open func itemSizeHeight(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> CGFloat {
    let config = KeyboardLayoutConfiguration.standard(for: context)
    return config.rowHeight
  }

  open func itemInsets(for action: KeyboardAction, row: Int, index: Int, keyboard: Keyboard, context: KeyboardContext) -> UIEdgeInsets {
    switch action {
    case .characterMargin, .none: return .zero
    default:
      if let insets = keyboard.buttonInsets {
        return insets
      }
      let config = KeyboardLayoutConfiguration.standard(for: context)
      return config.buttonInsets
    }
  }

  open func keyboardReturnAction(for context: KeyboardContext) -> KeyboardAction {
    let proxy = context.textDocumentProxy
    let returnType = proxy.returnKeyType?.keyboardReturnKeyType
    if let returnType { return .primary(returnType) }
    return .primary(.return)
  }
}
