import KeyboardKit
import SwiftUI

class HamsterKeyboardAppearance: StandardKeyboardAppearance {
  // 九宫格自定义背景色
  override func buttonBackgroundColor(for action: KeyboardAction, isPressed: Bool) -> Color {
    let isGridViewKeyboardType = keyboardContext.isGridViewKeyboardType
    if isGridViewKeyboardType {
      if case .character(let character) = action {
        let char = KeyboardConstant.Character(rawValue: character)
        if char != .none {
          return keyboardContext.hasDarkColorScheme ?
            .standardDarkButtonBackgroundForColorSchemeBug :
            .standardDarkButtonBackground
        }
      }
    }
    return super.buttonBackgroundColor(for: action, isPressed: isPressed)
  }
  
  // 自定义键盘文字国际化
  override func buttonText(for action: KeyboardAction) -> String? {
    action.hamsterButtonText(for: keyboardContext)
  }
}
