//
//  iPhoneChineseKeyboardLayoutProvider.swift
//  KeyboardKit

import UIKit

/**
 This class provides a keyboard layout that corresponds to a
 standard Chinese layout for an iPhone device.

 该类提供的键盘布局与 iPhone 设备的标准中文布局一致。

 You can inherit this class and override any open properties
 and functions to customize the standard behavior.

 您可以继承该类，并覆盖任何 open 的属性和函数，以自定义标准行为。
 */
open class iPhoneChineseKeyboardLayoutProvider: SystemKeyboardLayoutProvider {
  // MARK: - Overrides

  /**
   Get the keyboard actions for the `inputs` and `context`.

   获取 `inputs` 和 `context` 对应的键盘行操作。

   Note that `inputs` is an input set that doesn't contain
   the bottommost row. We therefore append it here.

   请注意，`inputs` 是一个不包含最下面一行的 InputSet。
   因此，我们将其追加到这里。
   */
  override open func actions(
    for inputs: InputSetRows,
    context: KeyboardContext
  ) -> KeyboardActionRows {
    let actions = super.actions(for: inputs, context: context)
    guard isExpectedActionSet(actions) else { return actions }
    var result = KeyboardActionRows()
    result.append(topLeadingActions(for: actions, context: context) + actions[0] + topTrailingActions(for: actions, context: context))
    result.append(middleLeadingActions(for: actions, context: context) + actions[1] + needsSemicolonButton(for: context) + middleTrailingActions(for: actions, context: context))
    result.append(lowerLeadingActions(for: actions, context: context) + actions[2] + lowerTrailingActions(for: actions, context: context))
    result.append(bottomActions(for: context))
    return result
  }

  /**
   Get the keyboard layout item width of a certain `action`
   for the provided `context`, `row` and row `index`.

   根据提供的 `context`、`row` 和行中 `index` 获取某个 `action` 的键盘布局 item 的宽度。
   */
  override open func itemSizeWidth(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext, actions: KeyboardActionRows) -> KeyboardLayoutItemWidth {
    switch action {
    // case context.keyboardDictationReplacement: return bottomSystemButtonWidth(for: context)
    case .character, .symbol: return isLastNumericInputRow(row, for: context) ? lastSymbolicInputWidth(for: context) : .input
    case .backspace: return lowerSystemButtonWidth(for: context)
    case .keyboardType(let type):
      /// 中文主键盘的最后一行第一个键
      if row == 3 && actions[row].count == 3 {
        return largeBottomWidth(for: context)
      }
      if row == 3 && actions[row].count == 4 && type.isNumber {
        return smallBottomWidth(for: context)
      }
      return bottomSystemButtonWidth(for: context)
    case .nextKeyboard: return bottomSystemButtonWidth(for: context)
    case .primary:
      if row == 3 && actions[row].count == 3 {
        return largeBottomWidth(for: context)
      }
      return smallBottomWidth(for: context)
    case .shift: return lowerSystemButtonWidth(for: context)
    default: return .available
    }
  }

  // MARK: - iPhone Specific iPhone 专用

  /**
   Additional leading actions to apply to the top row.

   应用于顶行的附加 leading 操作。
   */
  open func topLeadingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    guard shouldAddUpperMarginActions(for: actions, context: context) else { return [] }
    return [actions[0].leadingCharacterMarginAction]
  }

  /**
   Additional trailing actions to apply to the top row.

   应用于顶行的附加 trailing 操作。
   */
  open func topTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    guard shouldAddUpperMarginActions(for: actions, context: context) else { return [] }
    return [actions[0].trailingCharacterMarginAction]
  }

  /**
   Additional leading actions to apply to the middle row.

   应用于中间行的附加 leading 操作。
   */
  open func middleLeadingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    guard shouldAddMiddleMarginActions(for: actions, context: context) else { return [] }
    return [actions[1].leadingCharacterMarginAction]
  }

  /**
   Additional trailing actions to apply to the middle row.

   应用于中间行的附加 trailing 操作。
   */
  open func middleTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    guard shouldAddMiddleMarginActions(for: actions, context: context) else { return [] }
    return [actions[1].trailingCharacterMarginAction]
  }

  /**
   Additional leading actions to apply to the lower row.

   应用于下一行(相对与 middle 行)的附加 leading 操作。
   */
  open func lowerLeadingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    guard isExpectedActionSet(actions) else { return [] }
    let margin = actions[2].leadingCharacterMarginAction
    guard let switcher = keyboardSwitchActionForBottomInputRow(for: context) else { return [] }
    return [switcher, margin]
  }

  /**
   Additional trailing actions to apply to the lower row.

   应用于下一行(相对与 middle 行)的附加 trailing 操作。
   */
  open func lowerTrailingActions(
    for actions: KeyboardActionRows,
    context: KeyboardContext
  ) -> KeyboardActions {
    guard isExpectedActionSet(actions) else { return [] }
    let margin = actions[2].trailingCharacterMarginAction
    return [margin, .backspace]
  }

  /**
   The system buttons that are shown to the left and right
   of the third row's input buttons on a regular keyboard.

   在普通键盘第三行 input 类型按钮的左右两侧，显示的系统按钮（如删除键，Shift键）的布局 item 的宽度
   */
  open func lowerSystemButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    return .percentage(0.13)
  }

  /**
   The actions to add to the bottommost row.

   需要添加到最下面一行的操作。
   */
  open func bottomActions(
    for context: KeyboardContext
  ) -> KeyboardActions {
    var result = KeyboardActions()
    if let action = keyboardSwitchActionForBottomRow(for: context) { result.append(action) }

    let needsInputSwitch = context.needsInputModeSwitchKey
    if needsInputSwitch { result.append(.nextKeyboard) }

    if context.displayClassifySymbolButton {
      result.append(.keyboardType(.classifySymbolic))
    }

    if context.keyboardType.isChinesePrimaryKeyboard, context.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton, let action = needsChineseEnglishSwitchAction(for: context) {
      result.append(action)
    }

    if context.displaySpaceLeftButton {
      let action: KeyboardAction = context.spaceLeftButtonProcessByRIME
        ? .character(context.keyValueOfSpaceLeftButton)
        : .symbol(Symbol(char: context.keyValueOfSpaceLeftButton))
      result.append(action)
    }

    result.append(.space)

    if context.displaySpaceRightButton {
      let action: KeyboardAction = context.spaceRightButtonProcessByRIME
        ? .character(context.keyValueOfSpaceRightButton)
        : .symbol(Symbol(char: context.keyValueOfSpaceRightButton))
      result.append(action)
    }

    if context.keyboardType.isChinesePrimaryKeyboard, !context.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton, let action = needsChineseEnglishSwitchAction(for: context) {
      result.append(action)
    }

//    if context.textDocumentProxy.keyboardType == .emailAddress {
//      result.append(.symbol(.init(char: "@")))
//      result.append(.symbol(.init(char: ".")))
//    }
//    if context.textDocumentProxy.returnKeyType == .go {
//      result.append(.symbol(.init(char: ".")))
//    }
    result.append(keyboardReturnAction(for: context))
    return result
  }

  /**
   The width of bottom-right system buttons.

   最后面一行（空格所在行）右下角系统类型按键的宽度。
   */
  open func bottomSystemButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(isPortrait(context) ? 0.123 : 0.095)
  }

  /**
   Whether or not to add margin actions to the middle row.

   是否在中间行添加边距操作。
   */
  open func shouldAddMiddleMarginActions(for actions: KeyboardActionRows, context: KeyboardContext) -> Bool {
    guard isExpectedActionSet(actions) else { return false }
    return actions[0].count > actions[1].count
  }

  /**
   Whether or not to add margin actions to the upper row.

   是否为上一行添加边距操作。
   */
  open func shouldAddUpperMarginActions(for actions: KeyboardActionRows, context: KeyboardContext) -> Bool {
    false
  }
}

private extension iPhoneChineseKeyboardLayoutProvider {
  /// 操作行的行数是否符合预期
  func isExpectedActionSet(_ actions: KeyboardActionRows) -> Bool {
    actions.count == 3
  }

  /**
   The width of the last numeric/symbolic row input button.

   最后一个 数字/符号 行输入按键的宽度。
   */
  func lastSymbolicInputWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(0.115)
  }

  /**
   Whether or not a certain row is the last input row in a
   numeric or symbolic keyboard.

   判断某行是否为 数字/符号键盘 的最后输入行。
   */
  func isLastNumericInputRow(_ row: Int, for context: KeyboardContext) -> Bool {
    let isNumeric = context.keyboardType == .chineseNumeric
    let isSymbolic = context.keyboardType == .chineseSymbolic
    guard isNumeric || isSymbolic else { return false }
    return row == 2 // Index 2 is the "wide keys" row. index == 2 的行按键会宽一些
  }
}
