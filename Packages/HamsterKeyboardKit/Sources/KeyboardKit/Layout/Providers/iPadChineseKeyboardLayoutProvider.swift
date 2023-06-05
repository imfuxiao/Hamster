//
//  iPadChineseKeyboardLayoutProvider.swift
//  KeyboardKit
//
//

import UIKit

/**
 This class provides a keyboard layout that corresponds to a
 standard Chinese layout for an iPad with a home button.

 该类提供的键盘布局与带有主页按钮的 iPad 的标准中文布局一致。

 Note that this provider is currently used on all iPad types,
 including iPad Air and iPad Pro, although they use a layout
 that has more system buttons.

 请注意，目前包括 iPad Air 和 iPad Pro 在内的所有 iPad 类型都使用了这一 provider，
 不过它们使用的布局有更多的系统按钮。

 You can inherit this class and override any open properties
 and functions to customize the standard behavior.

 您可以继承该类，并覆盖任何 open 的属性和函数，以自定义标准行为。
 */
open class iPadChineseKeyboardLayoutProvider: SystemKeyboardLayoutProvider {
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
    guard actions.count == 3 else { return actions }
    var result = KeyboardActionRows()
    result.append(topLeadingActions(for: context) + actions[0] + topTrailingActions(for: context))
    result.append(middleLeadingActions(for: context) + actions[1] + needsSemicolonButton(for: context) + middleTrailingActions(for: context))
    result.append(lowerLeadingActions(for: context) + actions[2] + lowerTrailingActions(for: context))
    result.append(bottomActions(for: context))
    return result
  }

  /**
   Get the keyboard layout item width of a certain `action`
   for the provided `context`, `row` and row `index`.

   根据提供的 `context`、`row` 和行中的 `index`
   获取某个 `action` 的对应的键盘布局 item 的宽度。
   */
  override open func itemSizeWidth(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext, actions: KeyboardActionRows) -> KeyboardLayoutItemWidth {
    if isLowerTrailingSwitcher(action, row: row, index: index) { return .available }
    switch action {
    // case context.keyboardDictationReplacement: return .input
    case .primary, .keyboardType:
      if row == 1 {
        return .available
      }
    case .shift:
      if row == 2 {
        return .available
      }
    default: break
    }
    if action.isSystemAction { return systemButtonWidth(for: context) }
    return super.itemSizeWidth(for: action, row: row, index: index, context: context, actions: actions)
  }

  /**
   The return action to use for the provided `context`.

   根据提供的 `context`, 获取 Return 按键的类型
   */
  override open func keyboardReturnAction(
    for context: KeyboardContext
  ) -> KeyboardAction {
    let base = super.keyboardReturnAction(for: context)
    return base == .primary(.return) ? .primary(.newLine) : base
  }

  /**
   The standard system button width.

   标准系统按钮宽度。
   */
  open func systemButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    return .input
  }

  // MARK: - iPad Specific iPad 专用

  /**
   Additional leading actions to apply to the top row.

   应用于键盘顶行的附加 leading 操作。
   */
  open func topLeadingActions(for context: KeyboardContext) -> KeyboardActions {
    return [.tab]
  }

  /**
   Additional trailing actions to apply to the top row.

   应用于键盘顶行的附加 trailing 操作。
   */
  open func topTrailingActions(for context: KeyboardContext) -> KeyboardActions {
    return [.backspace]
  }

  /**
   Additional leading actions to apply to the middle row.

   应用于键盘中间行的附加 leading 操作。
   */
  open func middleLeadingActions(for context: KeyboardContext) -> KeyboardActions {
    return [.keyboardType(.alphabetic(.lowercased))]
  }

  /**
   Additional trailing actions to apply to the middle row.

   应用于键盘中间行的附加 trailing 操作。
   */
  open func middleTrailingActions(for context: KeyboardContext) -> KeyboardActions {
    return [keyboardReturnAction(for: context)]
  }

  /**
   Additional leading actions to apply to the lower row.

   应用于键盘最下面一行（相对 middle 行）的附加 leading 操作。
   */
  open func lowerLeadingActions(for context: KeyboardContext) -> KeyboardActions {
    guard let action = keyboardSwitchActionForBottomInputRow(for: context) else { return [] }
    return [action]
  }

  /**
   Additional trailing actions to apply to the lower row.

   应用于键盘最下面一行（相对 middle 行）的附加 trailing 操作。
   */
  open func lowerTrailingActions(for context: KeyboardContext) -> KeyboardActions {
    guard let action = keyboardSwitchActionForBottomInputRow(for: context) else { return [] }
    return [action]
  }

  /**
   The actions to add to the bottommost row.

   要添加到最下面一行的操作。
   */
  open func bottomActions(for context: KeyboardContext) -> KeyboardActions {
    var result = KeyboardActions()
    result.append(.nextKeyboard)
    if let action = keyboardSwitchActionForBottomRow(for: context) { result.append(action) }
    result.append(.keyboardType(.classifySymbolic))
    result.append(.space)
    if let action = keyboardSwitchActionForBottomRow(for: context) { result.append(action) }
    result.append(.dismissKeyboard)
    return result
  }
}

// MARK: - Private utils

private extension iPadChineseKeyboardLayoutProvider {
  /// 是否最下面一行（相对 middle 行）的键盘切换操作
  func isLowerTrailingSwitcher(_ action: KeyboardAction, row: Int, index: Int) -> Bool {
    switch action {
    case .shift, .keyboardType: return row == 2 && index > 0
    default: return false
    }
  }
}
