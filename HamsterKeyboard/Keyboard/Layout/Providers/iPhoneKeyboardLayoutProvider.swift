import Foundation
import KeyboardKit

class HamsteriPhoneKeyboardLayoutProvider: iPhoneKeyboardLayoutProvider {
  let appSettings: HamsterAppSettings
  let rimeEngine: RimeEngine
  let hamsterInputSetProvider: HamsterInputSetProvider

  init(inputSetProvider: HamsterInputSetProvider, appSettings: HamsterAppSettings, rimeEngine: RimeEngine) {
    self.appSettings = appSettings
    self.rimeEngine = rimeEngine
    self.hamsterInputSetProvider = inputSetProvider
    super.init(inputSetProvider: inputSetProvider)
  }

  // MARK: - Overrides

  override func inputRows(for context: KeyboardContext) -> InputSetRows {
    switch context.keyboardType {
    case .alphabetic: return hamsterInputSetProvider.alphabeticInputSet.rows
    case .numeric: return hamsterInputSetProvider.numericInputSet.rows
    case .symbolic: return hamsterInputSetProvider.symbolicInputSet.rows
    // TODO: 自定义键盘
//    case .custom(let name):
//      default:
//        return []
//      }
    default: return []
    }
  }

  /**
   Get keyboard actions for the `inputs` and `context`.

   Note that `inputs` is an input set and does not contain
   the bottommost space key row, which we therefore append.
   */
  override func actions(for inputs: InputSetRows, context: KeyboardContext) -> KeyboardActionRows {
//    let actions = super.actions(for: inputs, context: context)
//    let characters =

    let actions = KeyboardActionRows(characters: actionCharacters(for: inputs, context: context))

    // 数字九宫格布局
    if actions.count == 4, appSettings.enableNumberNineGrid {
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
        result.append(
          [.keyboardType(.alphabetic(.lowercased))] + actions[3] + [
            keyboardReturnAction(for: context)
          ])
      }
      return result
    }

    guard isExpectedActionSet(actions) else {
      return actions
    }

    var result = KeyboardActionRows()
    result.append(
      topLeadingActions(for: actions, context: context) + actions[0]
        + topTrailingActions(for: actions, context: context))

    result.append(
      middleLeadingActions(for: actions, context: context) + actions[1] +
        middleTrailingActions(for: actions, context: context))

    result.append(
      lowerLeadingActions(for: actions, context: context) + actions[2]
        + lowerTrailingActions(for: actions, context: context))
    result.append(bottomActions(for: context))
    return result
  }

  /**
   Get the keyboard layout item width of a certain `action`
   for the provided `context`, `row` and row `index`.
   */
  override func itemSizeWidth(
    for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayoutItemWidth
  {
    // 开启数字九宫格，数字键盘中按键宽度一致
    if appSettings.enableNumberNineGrid && context.keyboardType == .numeric {
      return .input
    }

    switch action {
    case context.keyboardDictationReplacement: return bottomSystemButtonWidth(for: context)
    case .character:
      return isLastNumericInputRow(row, for: context) ? lastSymbolicInputWidth(for: context) : .input
//    case .backspace: return context.isGridViewKeyboardType ? .input : lowerSystemButtonWidth(for: context)
    case .backspace: return lowerSystemButtonWidth(for: context)
//    case .keyboardType: return context.isGridViewKeyboardType ? .input : bottomSystemButtonWidth(for: context)
    case .keyboardType(let type):
      if context.keyboardType.isAlphabetic {
        return lastRowNoCharacterButtonWidth(for: context)
      }
      if context.keyboardType == .numeric && type.isAlphabetic {
        return lastRowNoCharacterButtonWidth(for: context)
      }
      if context.keyboardType == .symbolic && type.isAlphabetic {
        return lastRowNoCharacterButtonWidth(for: context)
      }
      return lowerSystemButtonWidth(for: context)
    case .nextKeyboard: return bottomSystemButtonWidth(for: context)
//    case .primary: return context.isGridViewKeyboardType ? .input : lastRowNoCharacterButtonWidth(for: context)
    case .primary: return lastRowNoCharacterButtonWidth(for: context)
    case .shift: return lowerSystemButtonWidth(for: context)
    case .custom: return .input
    case .image:
      // Logger.shared.log.debug("iPhoneKeyboardLayoutProvider itemSizeWidth(): image action, \(description), keyboardImageName = \(keyboardImageName), imageName = \(imageName)")
      return .input
    default: return .available
    }
  }

  // TODO: 通过此方法调节键盘高度
  // 注意: 这里是行高
  /**
   Get a layout item height for the provided parameters.
   */
//  override func itemSizeHeight(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> CGFloat {
//    let config = KeyboardLayoutConfiguration.standard(for: context)
//    return config.rowHeight
//  }

  // MARK: - iPhone Specific

  /**
   Get the actions of the bottommost space key row.
   */
  override func bottomActions(for context: KeyboardContext) -> KeyboardActions {
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

    // 底部根据配置, 添加自定义功能键
    if appSettings.showSpaceLeftButton {
      result.append(.custom(named: appSettings.spaceLeftButtonValue))
    }

    // 空格左侧添加中英文切换按键
    if appSettings.showSpaceRightSwitchLanguageButton && appSettings.switchLanguageButtonInSpaceLeft && context.keyboardType.isAlphabetic {
      result.append(switchLanguageButtonAction())
    }

    result.append(.space)

    if appSettings.showSpaceRightButton {
      result.append(.custom(named: appSettings.spaceRightButtonValue))
    }

    // 空格右侧添加中英文切换按键
    if appSettings.showSpaceRightSwitchLanguageButton && !appSettings.switchLanguageButtonInSpaceLeft && context.keyboardType.isAlphabetic {
      result.append(switchLanguageButtonAction())
    }

    // 根据当前上下文显示不同功能的回车键
    result.append(keyboardReturnAction(for: context))

    return result
  }

  // 中英文切换按钮Action
  func switchLanguageButtonAction() -> KeyboardAction {
    if rimeEngine.asciiMode {
      return .image(
        description: "中英切换",
        keyboardImageName: "",
        imageName: KeyboardConstant.ImageName.EnglishLanguageImageName)
    } else {
      return .image(
        description: "中英切换",
        keyboardImageName: "",
        imageName: KeyboardConstant.ImageName.ChineseLanguageImageName)
    }
  }

  override open func keyboardSwitchActionForBottomInputRow(for context: KeyboardContext) -> KeyboardAction? {
    switch context.keyboardType {
    case .alphabetic(let casing): return .shift(currentCasing: casing)
    case .numeric: return .keyboardType(.symbolic)
    case .symbolic: return .keyboardType(.numeric)
    default: return nil
    }
  }

  override open func keyboardSwitchActionForBottomRow(for context: KeyboardContext) -> KeyboardAction? {
    switch context.keyboardType {
    case .alphabetic:
      return .keyboardType(.numeric)
    case .numeric: return .keyboardType(.alphabetic(.auto))
    case .symbolic: return .keyboardType(.alphabetic(.auto))
    case .custom(let name):
      let customKeyboardType = KeyboardConstant.keyboardType(rawValue: name)
      switch customKeyboardType {
      case .numberNineGrid:
        return .keyboardType(.alphabetic(.auto))
      default:
        return .keyboardType(.alphabetic(.auto))
      }
    default: return nil
    }
  }

  override open func actionCharacters(for rows: InputSetRows, context: KeyboardContext) -> [[String]] {
    switch context.keyboardType {
    case .alphabetic(let casing): return rows.characters(for: casing)
    case .numeric: return rows.characters()
    case .symbolic: return rows.characters()
    case .custom: return rows.characters()
    default: return []
    }
  }
}

private extension HamsteriPhoneKeyboardLayoutProvider {
  func isExpectedActionSet(_ actions: KeyboardActionRows) -> Bool {
    actions.count >= 3
  }

  /**
   屏幕方向: 是否纵向
   */
  func isPortrait(_ context: KeyboardContext) -> Bool {
    context.interfaceOrientation.isPortrait
  }

  /**
   The width of the last numeric/symbolic row input button.
   */
  func lastSymbolicInputWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
//    .percentage(0.14)
    .percentage(0.12)
  }

  /**
   最后一行非字母按钮宽度
   */
  func lastRowNoCharacterButtonWidth(for context: KeyboardContext) -> KeyboardLayoutItemWidth {
    .percentage(isPortrait(context) ? 0.19 : 0.195)
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
