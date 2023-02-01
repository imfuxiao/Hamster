import Foundation
import KeyboardKit

class HamsteriPhoneKeyboardLayoutProvider: HamsterKeyboardLayoutProvider {
  // MARK: - Overrides
  
  /**
   Get keyboard actions for the `inputs` and `context`.
   
   Note that `inputs` is an input set and does not contain
   the bottommost space key row, which we therefore append.
   */
  override func actions(for inputs: InputSetRows, context: KeyboardContext) -> KeyboardActionRows {
    let actions = super.actions(for: inputs, context: context)
    
    // 九宫格布局
    if actions.count == 4, context.isGridViewKeyboardType {
      var result = KeyboardActionRows()
      // 第一行: 添加删除键
      result.append(actions[0] + [.backspace])
      result.append(actions[1])
      // 第三行: 添加符号键
      result.append([.keyboardType(.symbolic)] + actions[2])
      
      // 第四行: 添加键盘切换键
      if let action = keyboardSwitchActionForBottomRow(for: context) {
        result.append([action] + actions[3] + [keyboardReturnAction(for: context)])
      } else {
        // TODO: 如果不存在键盘切换键, 则手工添加字母键盘
        result.append([.keyboardType(.alphabetic(.lowercased))] + actions[3] + [keyboardReturnAction(for: context)])
      }
      return result
    }
      
    guard isExpectedPhoneInputActions(actions) else {
      return actions
    }
      
    let upper = actions[0]
    let middle = actions[1]
    let lower = actions[2]
    var result = KeyboardActionRows()
    result.append(upperLeadingActions(for: actions, context: context) + upper + upperTrailingActions(for: actions, context: context))
    result.append(middleLeadingActions(for: actions, context: context) + middle + middleTrailingActions(for: actions, context: context))
    result.append(lowerLeadingActions(for: actions, context: context) + lower + lowerTrailingActions(for: actions, context: context))
    result.append(bottomActions(for: context))
    return result
  }
  
  /**
   Get the keyboard layout item width of a certain `action`
   for the provided `context`, `row` and row `index`.
   */
  override func itemSizeWidth(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayoutItemWidth {
    let isGridViewKeyboard = context.isGridViewKeyboardType
    if action.isPrimaryAction { return isGridViewKeyboard ? .input : bottomPrimaryButtonWidth(for: context) }
    
    switch action {
    case context.keyboardDictationReplacement: return bottomSystemButtonWidth(for: context)
    
    // 字符
    case .character:
      if context.isAlphabetic(.greek) { return .percentage(0.1) }
      return isLastNumericInputRow(row, for: context) ? lastSymbolicInputWidth(for: context) : .input
      
    case .backspace: return isGridViewKeyboard ? .input : lowerSystemButtonWidth(for: context)
    case .keyboardType: return isGridViewKeyboard ? .input : bottomPrimaryButtonWidth(for: context)
    case .newLine: return isGridViewKeyboard ? .input : bottomPrimaryButtonWidth(for: context)
    case .nextKeyboard: return isGridViewKeyboard ? .input : bottomSystemButtonWidth(for: context)
    case .return: return isGridViewKeyboard ? .input : bottomPrimaryButtonWidth(for: context)
    case .shift: return lowerSystemButtonWidth(for: context)
    default: return .available
    }
  }
  
  // MARK: - iPhone Specific
  
  /**
   Get the actions of the bottommost space key row.
   */
  open func bottomActions(for context: KeyboardContext) -> KeyboardActions {
    var result = KeyboardActions()
    
    // 根据键盘类型不同显示不同的切换键: 如数字键盘/字母键盘等切换键
    if let action = keyboardSwitchActionForBottomRow(for: context) {
      result.append(action)
    }
    
    // 不同输入法切换键
    let needsInputSwitch = context.needsInputModeSwitchKey
    if needsInputSwitch { result.append(.nextKeyboard) }
    
    // emojis键盘
    // if !needsInputSwitch { result.append(.keyboardType(.emojis)) }
    
    // 空格
    result.append(.space)
    
    // 根据当前上下文显示不同功能的回车键
    result.append(keyboardReturnAction(for: context))
    
    return result
  }
  
  /**
   Get leading actions to add to the lower inputs row.
   */
  open func lowerLeadingActions(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardActions {
    guard isExpectedPhoneInputActions(actions) else { return [] }
    let margin = actions[2].leadingCharacterMarginAction
    guard let switcher = keyboardSwitchActionForBottomInputRow(for: context) else { return [] }
    return [switcher, margin]
  }
  
  /**
   Get trailing actions to add to the lower inputs row.
   */
  open func lowerTrailingActions(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardActions {
    guard isExpectedPhoneInputActions(actions) else { return [] }
    let margin = actions[2].trailingCharacterMarginAction
    return [margin, .backspace]
  }
  
  /**
   Get leading actions to add to the middle inputs row.
   */
  open func middleLeadingActions(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardActions {
    guard shouldAddMiddleMarginActions(for: actions, context: context) else { return [] }
    return [actions[1].leadingCharacterMarginAction]
  }
  
  /**
   Get trailing actions to add to the middle inputs row.
   */
  open func middleTrailingActions(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardActions {
    guard shouldAddMiddleMarginActions(for: actions, context: context) else { return [] }
    return [actions[1].trailingCharacterMarginAction]
  }
  
  /**
   Get leading actions to add to the upper inputs row.
   */
  open func upperLeadingActions(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardActions {
    let margin = actions[0].leadingCharacterMarginAction
    guard shouldAddUpperMarginActions(for: actions, context: context) else { return [] }
    return [margin]
  }
  
  /**
   Get trailing actions to add to the upper inputs row.
   */
  open func upperTrailingActions(for actions: KeyboardActionRows, context: KeyboardContext) -> KeyboardActions {
    let margin = actions[0].trailingCharacterMarginAction
    guard shouldAddUpperMarginActions(for: actions, context: context) else { return [] }
    return [margin]
  }
}

private extension HamsteriPhoneKeyboardLayoutProvider {
  func isExpectedPhoneInputActions(_ actions: KeyboardActionRows) -> Bool {
    actions.count == 3
  }
  
  /**
   屏幕方向: 是否纵向
   */
  func isPortrait(_ context: KeyboardContext) -> Bool {
    #if os(iOS)
      return context.interfaceOrientation.isPortrait
    #else
      return false
    #endif
  }
  
  /**
   The width of the last numeric/symbolic row input button.
   */
  func lastSymbolicInputWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(0.14)
  }
  
  /**
   The width of the bottom-right primary (return) button.
   */
  func bottomPrimaryButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(isPortrait(context) ? 0.25 : 0.195)
  }
  
  /**
   The width of the bottom-right primary (return) button.
   */
  func bottomSystemButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(isPortrait(context) ? 0.123 : 0.095)
  }
  
  /**
   The system buttons that are shown to the left and right
   of the third row's input buttons.
   */
  func lowerSystemButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    let bottomWidth = bottomSystemButtonWidth(for: context)
    let standard = isPortrait(context) ? bottomWidth : .percentage(0.12)
    return standard
  }
  
  /**
   Whether or not a certain row is the last input row in a
   numeric or symbolic keyboard.
   */
  func isLastNumericInputRow(_ row: Int, for context: KeyboardContext) -> Bool {
    let isNumeric = context.keyboardType == .numeric
    let isSymbolic = context.keyboardType == .symbolic
    guard isNumeric || isSymbolic else { return false }
    return row == 2 // Index 2 is the "wide keys" row
  }
  
  /**
   Whether or not to add margin actions to the middle row.
   */
  func shouldAddMiddleMarginActions(for actions: KeyboardActionRows, context: KeyboardContext) -> Bool {
    guard isExpectedPhoneInputActions(actions) else { return false }
    return actions[0].count > actions[1].count
  }
  
  /**
   Whether or not to add margin actions to the upper row.
   */
  func shouldAddUpperMarginActions(for actions: KeyboardActionRows, context: KeyboardContext) -> Bool {
    guard isExpectedPhoneInputActions(actions) else { return false }
    return false
  }
}

// MARK: - KeyboardContext Extension

private extension KeyboardContext {
  /// This function makes the context checks above shorter.
  func `is`(_ locale: KeyboardLocale) -> Bool {
    hasKeyboardLocale(locale)
  }
  
  /// This function makes the context checks above shorter.
  func isAlphabetic(_ locale: KeyboardLocale) -> Bool {
    hasKeyboardLocale(locale) && keyboardType.isAlphabetic
  }
}
