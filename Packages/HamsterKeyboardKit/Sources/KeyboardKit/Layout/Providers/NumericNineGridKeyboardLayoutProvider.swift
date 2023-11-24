//
//  NumericNineGridKeyboardLayoutProvider.swift
//
//
//  Created by morse on 2023/9/6.
//

import UIKit

/// 数字九宫格布局 Provider
open class NumericNineGridKeyboardLayoutProvider: KeyboardLayoutProvider {
  static let inputRows: InputSetRows = [
    [InputSetItem("1"), InputSetItem("2"), InputSetItem("3")],
    [InputSetItem("4"), InputSetItem("5"), InputSetItem("6")],
    [InputSetItem("7"), InputSetItem("8"), InputSetItem("9")],
    [InputSetItem("0")],
  ]

  static let insets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)

  private let keyboardContext: KeyboardContext

  public var insets: UIEdgeInsets {
    Self.insets
  }

  init(keyboardContext: KeyboardContext) {
    self.keyboardContext = keyboardContext
  }

  public func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    let inputs = inputRows(for: context)
    let actions = self.actions(for: inputs, context: context)
    // TODO: 这里添加 swipe 属性
    let items = self.items(for: actions, context: context)
    return KeyboardLayout(itemRows: items)
  }

  public func register(inputSetProvider: InputSetProvider) {
    // TODO: 不需要实现此方法
  }

  open func inputRows(for context: KeyboardContext) -> InputSetRows {
    return Self.inputRows
  }

  open func actions(for rows: InputSetRows, context: KeyboardContext) -> KeyboardActionRows {
    let inputActions = keyboardContext.numberKeyProcessByRimeOnNineGridOfNumericKeyboard
      ? KeyboardActionRows(characters: rows.characters())
      : KeyboardActionRows(symbols: rows.characters())
    var result = KeyboardActionRows()
    result.append(inputActions[0] + topTrailingActions(for: inputActions, context: context))
    result.append(inputActions[1] + middleTrailingActions(for: inputActions, context: context))
    result.append(inputActions[2] + lowerTrailingActions(for: inputActions, context: context))
    result.append(bottomLeadingActions(for: inputActions, context: context) + inputActions[3] + bottomTrailingActions(for: inputActions, context: context))
    return result
  }

  open func items(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardLayoutItemRows {
    actions.enumerated().map { row in
      row.element.enumerated().map { action in
        // TODO: 这里添加 swipe 属性
        item(for: action.element, row: row.offset, index: action.offset, context: context)
      }
    }
  }

  open func item(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayoutItem {
    let size = itemSize(for: action, row: row, index: index, context: context)
    let insets = Self.insets
    let swipes = itemSwipes(for: action, row: row, index: index, context: context)
    return KeyboardLayoutItem(action: action, size: size, insets: insets, swipes: swipes)
  }

  open func itemSize(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayoutItemSize {
    let width = itemSizeWidth(for: action, row: row, index: index, context: context)
    let height = itemSizeHeight(for: action, row: row, index: index, context: context)
    return KeyboardLayoutItemSize(width: width, height: height)
  }

  open func itemSizeWidth(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayoutItemWidth {
    switch action {
    case .character: return .input
    default: return .available
    }
  }

  open func itemSizeHeight(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> CGFloat {
    let config = KeyboardLayoutConfiguration.standard(for: context)
    return config.rowHeight
  }

  open func itemInsets(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> UIEdgeInsets {
    let config = KeyboardLayoutConfiguration.standard(for: context)
    switch action {
    case .characterMargin, .none: return .zero
    default: return config.buttonInsets
    }
  }

  open func itemSwipes(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> [KeySwipe] {
    if let swipe = context.keyboardSwipe[context.keyboardType]?[action] {
      return swipe
    }
    return []
  }

  open func keyboardReturnAction(for context: KeyboardContext) -> KeyboardAction {
    let proxy = context.textDocumentProxy
    let returnType = proxy.returnKeyType?.keyboardReturnKeyType
    if let returnType { return .primary(returnType) }
    return .primary(.return)
  }

  /**
   应用于顶行的附加 trailing 操作。
   */
  open func topTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    return [.backspace]
  }

  /**
   应用于中间行的附加 trailing 操作。
   */
  open func middleTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    let action: KeyboardAction = keyboardContext.rightSymbolProcessByRimeOnNineGridOfNumericKeyboard
      ? .characterOfDark(".")
      : .symbolOfDark(.init(char: "."))
    return [action]
  }

  /**
   应用于下一行(相对与 middle 行)的附加 trailing 操作。
   */
  open func lowerTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    let action: KeyboardAction = keyboardContext.rightSymbolProcessByRimeOnNineGridOfNumericKeyboard
      ? .characterOfDark("@")
      : .symbolOfDark(.init(char: "@"))
    return [action]
  }

  /**
   应用于下一行(相对与 middle 行)的附加 leading 操作。
   */
  open func bottomLeadingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    return [.returnLastKeyboard, .keyboardType(.classifySymbolicOfLight)]
  }

  /**
    最下面一行
   */
  open func bottomTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    return [.space, keyboardReturnAction(for: context)]
  }

  /// 最后面一行（空格所在行）小的按钮(如 `Return` 键)的宽度。
  /// 注意：当系统为最后一行添加了更多的按键，则会使用此宽度
  open func smallBottomWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(keyboardContext.interfaceOrientation.isPortrait ? 0.165 : 0.135)
  }
}
