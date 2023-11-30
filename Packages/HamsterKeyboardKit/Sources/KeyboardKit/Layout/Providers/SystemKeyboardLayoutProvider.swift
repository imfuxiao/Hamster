//
//  SystemKeyboardLayoutProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-02.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics
import UIKit

/**
 This is a base class for any keyboard layout providers that
 need basic functionality for system keyboard layouts.

 该基类适用于任何需要系统键盘布局基本功能的键盘布局 Provider。

 The class is used by the ``iPadKeyboardLayoutProvider`` and
 and the ``iPhoneKeyboardLayoutProvider``, since they aim to
 create platforms-specific system keyboard layouts.

 ``iPadKeyboardLayoutProvider`` 和 ``iPhoneKeyboardLayoutProvider`` 使用该类，
 因为它们旨在创建特定平台的系统键盘布局。

 Since keyboard extensions don't support `dictation` without
 having to jump through hoops (see SwiftKey) the initializer
 has a `dictationReplacement` parameter, that can be used to
 place another action where the dictation key would go.

 由于键盘扩展不支持 `dictation` 听写，因此必须通过重重关卡（参见 SwiftKey），
 因此初始化器有一个 `dictationReplacement` 参数，可用于在听写键的位置放置其他操作。

 If you want to create an entirely custom layout, you should
 just implement `KeyboardLayoutProvider`.

 如果要创建完全自定义的布局，只需实现 `KeyboardLayoutProvider` 即可。
 */
open class SystemKeyboardLayoutProvider: KeyboardLayoutProvider {
  // MARK: - Properties

  /**
   The input set provider to use.

   使用的 InputSetProvider。
   */
  public var inputSetProvider: InputSetProvider

  // MARK: - Initializations

  /**
   Create a system keyboard layout provider.

   - Parameters:
     - inputSetProvider: The input set provider to use.
   */
  public init(inputSetProvider: InputSetProvider) {
    self.inputSetProvider = inputSetProvider
  }

  // MARK: - Functions

  /**
   Get a keyboard layout for a certain keyboard `context`.

   获取特定键盘`context`的键盘布局。
   */
  open func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    let inputs = inputRows(for: context)
    let actions = self.actions(for: inputs, context: context)
    let items = self.items(for: actions, context: context)
    return KeyboardLayout(itemRows: items)
  }

  /**
   Register a new input set provider.

   注册新的 InputSetProvider。
   */
  open func register(inputSetProvider: InputSetProvider) {
    self.inputSetProvider = inputSetProvider
  }

  // MARK: - Overridable helper functions 可重写的辅助函数

  /**
   Get keyboard actions for the `inputs` and `context`.

   获取 `inputs` 和 `context` 对应的键盘行操作。
   */
  open func actions(for rows: InputSetRows, context: KeyboardContext) -> KeyboardActionRows {
    let characters = actionCharacters(for: rows, context: context)
    if context.keyboardType == .chineseNumeric || context.keyboardType == .chineseSymbolic || context.keyboardType == .numeric || context.keyboardType == .symbolic {
      return KeyboardActionRows(symbols: characters)
    }
    return KeyboardActionRows(characters: characters)
  }

  /**
   Get actions characters for the `inputs` and `context`.

   获取 `inputs` 和 `context` 对应的操作字符。
   */
  open func actionCharacters(for rows: InputSetRows, context: KeyboardContext) -> [[String]] {
    switch context.keyboardType {
    case .alphabetic(let casing): return rows.characters(for: casing)
    case .chinese(let casing): return rows.characters(for: casing)
    case .numeric: return rows.characters()
    case .chineseNumeric: return rows.characters()
    case .symbolic: return rows.characters()
    case .chineseSymbolic: return rows.characters()
    default: return []
    }
  }

  /**
   Get input set rows for the provided `context`.

   获取的`context`中对应的 InputSetRows。
   */
  open func inputRows(for context: KeyboardContext) -> InputSetRows {
    switch context.keyboardType {
    case .chinese: return inputSetProvider.alphabeticInputSet.rows
    case .chineseNumeric: return inputSetProvider.numericInputSet.rows
    case .chineseSymbolic: return inputSetProvider.symbolicInputSet.rows
    case .alphabetic: return inputSetProvider.alphabeticInputSet.rows
    case .numeric: return inputSetProvider.numericInputSet.rows
    case .symbolic: return inputSetProvider.symbolicInputSet.rows
    default: return []
    }
  }

  /**
   Get layout item rows for the `actions` and `context`.

   获取对应 `actions` 和 `context` 的 KeyboardLayoutItemRows。
   */
  open func items(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardLayoutItemRows {
    actions.enumerated().map { row in
      row.element.enumerated().map { action in
        item(for: action.element, row: row.offset, index: action.offset, context: context, actions: actions)
      }
    }
  }

  /**
   Get a layout item for the provided parameters.

   根据提供的布局参数获取 KeyboardLayoutItem。
   */
  open func item(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext, actions: KeyboardActionRows) -> KeyboardLayoutItem {
    let size = itemSize(for: action, row: row, index: index, context: context, actions: actions)
    let insets = itemInsets(for: action, row: row, index: index, context: context)
    let swipes = itemSwipes(for: action, row: row, index: index, context: context)
    return KeyboardLayoutItem(action: action, size: size, insets: insets, swipes: swipes)
  }

  /**
   Get a layout item size for the provided parameters.

   根据提供的布局参数获取布局项的 KeyboardLayoutItemSize。
   */
  open func itemSize(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext, actions: KeyboardActionRows) -> KeyboardLayoutItemSize {
    let width = itemSizeWidth(for: action, row: row, index: index, context: context, actions: actions)
    let height = itemSizeHeight(for: action, row: row, index: index, context: context)
    return KeyboardLayoutItemSize(width: width, height: height)
  }

  /**
   Get layout item insets for the provided parameters.

   根据提供的布局参数获取布局 item 的内嵌。
   */
  open func itemInsets(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> UIEdgeInsets {
    let config = KeyboardLayoutConfiguration.standard(for: context)
    switch action {
    case .characterMargin, .none: return .zero
    default: return config.buttonInsets
    }
  }

  /**
   根据提供的布局参数获取布局 item 的划动配置。
   */
  open func itemSwipes(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> [KeySwipe] {
    let keyboardTypeKey: KeyboardType = {
      if context.keyboardType.isChinesePrimaryKeyboard {
        return .chinese(.lowercased)
      }
      if context.keyboardType.isAlphabetic {
        return .alphabetic(.lowercased)
      }
      if case .custom(let named, _) = context.keyboardType {
        return .custom(named: named, case: .lowercased)
      }
      return context.keyboardType
    }()

    let actionKey: KeyboardAction = {
      if case .character(let char) = action {
        return .character(char.lowercased())
      }
      if case .symbol(let symbol) = action {
        return .symbol(Symbol(char: symbol.char.lowercased()))
      }
      return action
    }()

    if let swipe = context.keyboardSwipe[keyboardTypeKey]?[actionKey] {
      return swipe
    }
    return []
  }

  /**
   Get a layout item height for the provided parameters.

   根据提供的参数获取布局 item 的高度。
   */
  open func itemSizeHeight(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> CGFloat {
    let config = KeyboardLayoutConfiguration.standard(for: context)
    return config.rowHeight
  }

  /**
   Get a layout item width for the provided parameters.

   根据提供的参数获取布局 item 的宽度。
   */
  open func itemSizeWidth(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext, actions: KeyboardActionRows) -> KeyboardLayoutItemWidth {
    switch action {
    case .character, .symbol: return .input
    default: return .available
    }
  }

  /// 最后面一行（空格所在行）大的按钮(如 `Return` 键)的宽度。
  /// 当系统只有三个按钮时
  open func largeBottomWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(isPortrait(context) ? 0.25 : 0.195)
  }

  /// 最后面一行（空格所在行）小的按钮(如 `Return` 键)的宽度。
  /// 注意：当系统为最后一行添加了更多的按键，则会使用此宽度
  open func smallBottomWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(isPortrait(context) ? 0.19 : 0.135)
  }

  /// 屏幕是否为纵向
  open func isPortrait(_ context: KeyboardContext) -> Bool {
    context.interfaceOrientation.isPortrait
  }

  /**
   The return action to use for the provided `context`.

   根据提供的 `context`, 获取 Return 按键的类型
   */
  open func keyboardReturnAction(for context: KeyboardContext) -> KeyboardAction {
    let proxy = context.textDocumentProxy
    let returnType = proxy.returnKeyType?.keyboardReturnKeyType
    if let returnType { return .primary(returnType) }
    return .primary(.return)
  }

  /**
   The keyboard switch action that should be on the bottom
   input row, which is the row above the bottommost row.

   根据 `context` 当前键盘类型，返回对应的键盘切换操作。
   注意：此操作对应最底行上方的一行，即键盘的倒数第二行。
   */
  open func keyboardSwitchActionForBottomInputRow(for context: KeyboardContext) -> KeyboardAction? {
    switch context.keyboardType {
    case .chinese(let casing): return .shift(currentCasing: casing)
    case .alphabetic(let casing): return .shift(currentCasing: casing)
    case .numeric: return context.enableClassifySymbolicKeyboard ? .keyboardType(.classifySymbolic) : .keyboardType(.symbolic)
    case .chineseNumeric: return context.enableClassifySymbolicKeyboard ? .keyboardType(.classifySymbolic) : .keyboardType(.chineseSymbolic)
    case .symbolic: return context.enableNineGridOfNumericKeyboard ? .keyboardType(.numericNineGrid) : .keyboardType(.numeric)
    case .chineseSymbolic: return context.enableNineGridOfNumericKeyboard ? .keyboardType(.numericNineGrid) : .keyboardType(.chineseNumeric)
    default: return nil
    }
  }

  /**
   The keyboard switch action that should be on the bottom
   keyboard row, which is the row with the space button.

   根据 `context` 当前键盘类型，返回对应的键盘切换操作。
   注意：此操作对应键盘最底行，即键盘的倒数第一行。
   */
  open func keyboardSwitchActionForBottomRow(for context: KeyboardContext) -> KeyboardAction? {
    switch context.keyboardType {
    case .chinese: return context.enableNineGridOfNumericKeyboard ? .keyboardType(.numericNineGrid) : .keyboardType(.chineseNumeric)
    case .alphabetic: return context.enableNineGridOfNumericKeyboard ? .keyboardType(.numericNineGrid) : .keyboardType(.numeric)
    case .numeric: return .keyboardType(.alphabetic(.auto))
    case .chineseNumeric: return .keyboardType(.chinese(.lowercased))
    case .symbolic: return .keyboardType(.alphabetic(.auto))
    case .chineseSymbolic: return .keyboardType(.chinese(.lowercased))
    default: return nil
    }
  }

  /**
   是否需要中英切换按键
   */
  open func needsChineseEnglishSwitchAction(for context: KeyboardContext) -> KeyboardAction? {
    if context.displayChineseEnglishSwitchButton {
      return .keyboardType(.alphabetic(.lowercased))
    }
    return nil
  }

  /// 是否添加分号键
  open func needsSemicolonButton(for context: KeyboardContext) -> KeyboardActions {
    context.displaySemicolonButton ? [.character(";")] : []
  }
}
