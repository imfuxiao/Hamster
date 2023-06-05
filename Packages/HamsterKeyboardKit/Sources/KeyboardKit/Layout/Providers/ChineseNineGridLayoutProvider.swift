//
//  File.swift
//
//
//  Created by morse on 2023/9/8.
//

import UIKit

/// 中文九宫格布局
public class ChineseNineGridLayoutProvider: KeyboardLayoutProvider {
  static let actionRows: KeyboardActionRows = [
    [.chineseNineGrid(Symbol(char: "@/.")), .chineseNineGrid(Symbol(char: "ABC")), .chineseNineGrid(Symbol(char: "DEF")), .backspace],
    // TODO: 分词
//    [.delimiter, .chineseNineGrid(Symbol(char: "ABC")), .chineseNineGrid(Symbol(char: "DEF")), .backspace],
    [.chineseNineGrid(Symbol(char: "GHI")), .chineseNineGrid(Symbol(char: "JKL")), .chineseNineGrid(Symbol(char: "MNO")), .cleanSpellingArea],
    [.chineseNineGrid(Symbol(char: "PQRS")), .chineseNineGrid(Symbol(char: "TUV")), .chineseNineGrid(Symbol(char: "WXYZ"))],
    [.keyboardType(.classifySymbolic), .keyboardType(.numericNineGrid), .space, .keyboardType(.alphabetic(.lowercased))],
  ]

  static let insets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)

  public var insets: UIEdgeInsets {
    Self.insets
  }

  public func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    let actions = actions(context: context)
    // TODO: 这里添加 swipe 属性
    let items = self.items(for: actions, context: context)
    return KeyboardLayout(itemRows: items)
  }

  public func register(inputSetProvider: InputSetProvider) {
    // TODO: 不需要实现此方法
  }

  open func actions(context: KeyboardContext) -> KeyboardActionRows {
    let inputActions = Self.actionRows
    var result = KeyboardActionRows()
    result.append(inputActions[0])
    result.append(inputActions[1])
    result.append(inputActions[2] + lowerTrailingActions(for: inputActions, context: context))
    result.append(inputActions[3])
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
   应用于下一行(相对与 middle 行)的附加 trailing 操作。
   */
  open func lowerTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    return [keyboardReturnAction(for: context)]
  }

  /// 最后面一行（空格所在行）小的按钮(如 `Return` 键)的宽度。
  /// 注意：当系统为最后一行添加了更多的按键，则会使用此宽度
  open func smallBottomWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(context.interfaceOrientation.isPortrait ? 0.165 : 0.135)
  }

  /**
   The system buttons that are shown to the left and right
   of the third row's input buttons on a regular keyboard.

   在普通键盘第三行 input 类型按钮的左右两侧，显示的系统按钮（如删除键，Shift键）的布局 item 的宽度
   */
  open func lowerSystemButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    return .percentage(0.13)
  }
}
