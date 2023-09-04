//
//  File.swift
//
//
//  Created by morse on 2023/9/4.
//

import Foundation

/// 自定义键盘布局 Provider
open class CustomizeKeyboardLayoutProvider: SystemKeyboardLayoutProvider {
  /// 自定义键盘
  private let keyboards: [Keyboard]

  init(inputSetProvider: InputSetProvider, keyboards: [Keyboard]) {
    self.keyboards = keyboards

    super.init(inputSetProvider: inputSetProvider)
  }

  override public func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    guard context.keyboardType.isCustom else { return super.keyboardLayout(for: context) }
    guard case .custom(let name) = context.keyboardType else { fatalError("keyboard custom name is empty") }
    let actions = self.actions(name)

    // TODO: 这里添加 swipe 属性
    let items = self.items(for: actions, context: context)
    return KeyboardLayout(itemRows: items)
  }

  /**
   获取自定义键盘 actions
   */
  func actions(_ name: String) -> KeyboardActionRows {
    guard let keyboard = keyboards.first(where: { $0.name == name }) else { return [] }
    return keyboard.rows.map { $0.keys.map { $0.action } }
  }
}
