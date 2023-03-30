import KeyboardKit
import SwiftUI

class HamsterKeyboardAppearance: StandardKeyboardAppearance {
  var ivc: HamsterKeyboardViewController
  var appSettings: HamsterAppSettings
  var rimeEngine: RimeEngine

  public init(ivc: HamsterKeyboardViewController) {
    self.ivc = ivc
    self.appSettings = ivc.appSettings
    self.rimeEngine = ivc.rimeEngine
    super.init(keyboardContext: ivc.keyboardContext)
  }

  // 九宫格自定义背景色
  override func buttonBackgroundColor(for action: KeyboardAction, isPressed: Bool) -> Color {
    let isGridViewKeyboardType = keyboardContext.isGridViewKeyboardType
    if isGridViewKeyboardType {
      if case .character(let character) = action {
        let char = KeyboardConstant.Character(rawValue: character)
        if char != .none {
          return keyboardContext.hasDarkColorScheme
            ? .standardDarkButtonBackgroundForColorSchemeBug : .standardDarkButtonBackground
        }
      }
    }
    return super.buttonBackgroundColor(for: action, isPressed: isPressed)
  }

  // TODO: 图片按钮
  override func buttonImage(for action: KeyboardAction) -> Image? {
    action.standardButtonImage(for: keyboardContext)
  }

  // 自定义键盘文字国际化
  override func buttonText(for action: KeyboardAction) -> String? {
    action.hamsterButtonText(for: keyboardContext)
  }

  // TODO: 根据 squirrel 颜色方案动态变更
  override func buttonStyle(for action: KeyboardAction, isPressed: Bool) -> KeyboardButtonStyle {
    if appSettings.enableRimeColorSchema {
      let colorSchema = rimeEngine.currentColorSchema
      return KeyboardButtonStyle(
        backgroundColor: colorSchema.backColor,
        foregroundColor: colorSchema.candidateTextColor ?? buttonForegroundColor(for: action, isPressed: isPressed),
        font: buttonFont(for: action),
        cornerRadius: buttonCornerRadius(for: action),
        border: KeyboardButtonBorderStyle(color: colorSchema.borderColor ?? .clearInteractable, size: 1),
        shadow: .noShadow
      )
    }
    return KeyboardButtonStyle(
      backgroundColor: buttonBackgroundColor(for: action, isPressed: isPressed),
      foregroundColor: buttonForegroundColor(for: action, isPressed: isPressed),
      font: buttonFont(for: action),
      cornerRadius: buttonCornerRadius(for: action),
      border: buttonBorderStyle(for: action),
      shadow: buttonShadowStyle(for: action)
    )
  }
}
