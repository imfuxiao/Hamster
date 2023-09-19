//
//  CustomizeKeyboardLayoutProvider.swift
//
//
//  Created by morse on 2023/9/4.
//

import UIKit

/// 自定义键盘布局 Provider
open class CustomizeKeyboardLayoutProvider: KeyboardLayoutProvider {
  private let keyboardLayoutProvider: KeyboardLayoutProvider

  /// 自定义键盘
  private let keyboards: [Keyboard]

  init(keyboardLayoutProvider: KeyboardLayoutProvider, keyboards: [Keyboard]) {
    self.keyboardLayoutProvider = keyboardLayoutProvider
    self.keyboards = keyboards
  }

  public func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    // 非自定义键盘返回其他 provider
    guard context.keyboardType.isCustom else { return keyboardLayout(for: context) }
    guard case .custom(let name) = context.keyboardType else { return keyboardLayout(for: context) }
    guard let keyboard = keyboards.first(where: { $0.name == name }) else { return keyboardLayout(for: context) }
    let actions = self.actions(keyboard: keyboard)
    let items = self.items(for: actions, keyboard: keyboard, context: context)
    return KeyboardLayout(itemRows: items, customKeyboard: keyboard)
  }

  public func register(inputSetProvider: InputSetProvider) {
    // 不需要实现
  }

  /**
   获取自定义键盘 actions
   */
  open func actions(keyboard: Keyboard) -> KeyboardActionRows {
    return keyboard.rows.map { $0.keys.map { $0.action } }
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
      return KeyboardLayoutItemSize(width: width, height: height)
    }

    /// 键盘配置全局高度次优先
    if let height = keyboard.rowHeight {
      return KeyboardLayoutItemSize(width: width, height: height)
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
