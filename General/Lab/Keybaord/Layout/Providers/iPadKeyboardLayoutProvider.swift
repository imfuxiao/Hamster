import Foundation
import KeyboardKit

class HamsteriPadKeyboardLayoutProvider: iPadKeyboardLayoutProvider {
  init(inputSetProvider: HamsterInputSetProvider, appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
    self.hamsterInputSetProvider = inputSetProvider
    super.init(inputSetProvider: inputSetProvider)
  }
  
  let appSettings: HamsterAppSettings
  let rimeContext: RimeContext
  let hamsterInputSetProvider: HamsterInputSetProvider
  
  /**
   Get the keyboard layout item width of a certain `action`
   for the provided `context`, `row` and row `index`.
   */
  override func itemSizeWidth(
    for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayoutItemWidth
  {
    // 自定义键盘类型宽度一致
    if case .custom = context.keyboardType {
      return .input
    }
    
    switch action {
    // 自定义按键
    case .image, .custom:
      return .input
    default:
      return super.itemSizeWidth(for: action, row: row, index: index, context: context)
    }
  }
  
  /**
   The actions to add to the bottommost row.
   */
  override func bottomActions(for context: KeyboardContext) -> KeyboardActions {
    var result = KeyboardActions()
    
    // 根据键盘类型不同显示不同的切换键: 如数字键盘/字母键盘等切换键
    if let action = keyboardSwitchActionForBottomRow(for: context) {
      result.append(action)
    }

    // 不同输入法切换键（小地球）
    if context.needsInputModeSwitchKey {
      result.append(.nextKeyboard)
    }
    
    // 听写键
    if context.hasDictationKey {
      if let action = context.keyboardDictationReplacement {
        result.append(action)
      } else {
        result.append(.dictation)
      }
    }
    
    // 底部根据配置, 添加自定义功能键
    if appSettings.showSpaceLeftButton {
      result.append(.custom(named: appSettings.spaceLeftButtonValue))
    }
    
    // 空格左侧添加中英文切换按键
    if appSettings.showSpaceRightSwitchLanguageButton && appSettings.switchLanguageButtonInSpaceLeft && context.keyboardType.isAlphabetic {
      result.append(switchLanguageButtonAction())
    }
    
    // 空格键
    result.append(.space)
    
    // 底部根据配置, 添加自定义功能键
    if appSettings.showSpaceRightButton {
      result.append(.custom(named: appSettings.spaceRightButtonValue))
    }

    // 空格右侧添加中英文切换按键
    if appSettings.showSpaceRightSwitchLanguageButton && !appSettings.switchLanguageButtonInSpaceLeft && context.keyboardType.isAlphabetic {
      result.append(switchLanguageButtonAction())
    }
    
    // 根据键盘类型不同显示不同的切换键: 如数字键盘/字母键盘等切换键
    if let action = keyboardSwitchActionForBottomRow(for: context) {
      result.append(action)
    }
    
    // 收起键盘
    result.append(.dismissKeyboard)
    
    return result
  }

  // 中英文切换按钮Action
  func switchLanguageButtonAction() -> KeyboardAction {
    return .image(
      description: "中英切换",
      keyboardImageName: "",
      imageName: KeyboardConstant.ImageName.switchLanguage)
  }
}
