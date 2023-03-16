import KeyboardKit
import SwiftUI

class HamsterKeyboardAppearance: StandardKeyboardAppearance {
  var appSettings: HamsterAppSettings
  var rimeEngine: RimeEngine

  public init(keyboardContext: KeyboardContext, appSettings: HamsterAppSettings, rimeEngine: RimeEngine) {
    self.appSettings = appSettings
    self.rimeEngine = rimeEngine

    super.init(keyboardContext: keyboardContext)
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
    if appSettings.rimeEnableColorSchema {
      if let colorSchema = rimeEngine.colorSchema().first(where: { $0.schemaName == appSettings.rimeColorSchema }) {
        return KeyboardButtonStyle(
          backgroundColor: colorSchema.backColor.bgrColor ?? buttonBackgroundColor(for: action, isPressed: isPressed),
          foregroundColor: colorSchema.candidateTextColor.bgrColor ?? buttonForegroundColor(for: action, isPressed: isPressed),
          font: buttonFont(for: action),
          cornerRadius: buttonCornerRadius(for: action),
          border: KeyboardButtonBorderStyle(color: colorSchema.borderColor.bgrColor ?? .clear, size: 1) ,
          shadow: .noShadow
        )
      }
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
