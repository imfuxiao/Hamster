import KeyboardKit
import SwiftUI

class HamsterKeyboardAppearance: StandardKeyboardAppearance {
  var appSettings: HamsterAppSettings
  var rimeEngine: RimeEngine

  public init(
    keyboardContext: KeyboardContext,
    rimeEngine: RimeEngine,
    appSettings: HamsterAppSettings
  ) {
    self.appSettings = appSettings
    self.rimeEngine = rimeEngine
    super.init(keyboardContext: keyboardContext)
  }

  /**
   The button font to use for a certain action.
   */
  override func buttonFont(for action: KeyboardAction) -> Font {
    let rawFont = Font.system(size: buttonFontSize(for: action))
    guard let weight = buttonFontWeight(for: action) else { return rawFont }
    return rawFont.weight(weight)
  }

  /**
   The button font size to use for a certain action.
   */
  override func buttonFontSize(for action: KeyboardAction) -> CGFloat {
    if let override = buttonFontSizePadOverride(for: action) { return override }
    if buttonImage(for: action) != nil { return 20 }
    if let override = buttonFontSizeActionOverride(for: action) { return override }
    let text = buttonText(for: action) ?? ""
    if action.isInputAction && text.isLowercased { return 26 }
    if action.isSystemAction || action.isPrimaryAction { return 16 }
    return 23
  }

  /**
   The button font size to force override for iPad devices.
   */
  func buttonFontSizePadOverride(for action: KeyboardAction) -> CGFloat? {
    guard keyboardContext.deviceType == .pad else { return nil }
    let isLandscape = keyboardContext.interfaceOrientation.isLandscape
    guard isLandscape else { return nil }
    if action.isAlphabeticKeyboardTypeAction { return 22 }
    if action.isKeyboardTypeAction(.numeric) { return 22 }
    if action.isKeyboardTypeAction(.symbolic) { return 20 }
    return nil
  }

  /**
   The button font size to force override for some actions.
   */
  func buttonFontSizeActionOverride(for action: KeyboardAction) -> CGFloat? {
    switch action {
    case .keyboardType(let type): return buttonFontSize(for: type)
    case .space: return 16
    default: return nil
    }
  }

  /**
   The button font size to use for a certain keyboard type.
   */
  override func buttonFontSize(for keyboardType: KeyboardType) -> CGFloat {
    switch keyboardType {
    case .alphabetic: return 15
    case .numeric: return 16
    case .symbolic: return 14
    default: return 14
    }
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
    if let image = action.hamsterButtonImage(for: keyboardContext) {
      return image
    }
    return action.standardButtonImage(for: keyboardContext)
  }

  /**
   The scale factor to apply to the button content, if any.
   */
  override func buttonImageScaleFactor(for action: KeyboardAction) -> CGFloat {
    switch keyboardContext.deviceType {
    case .pad: return 1.2
    default: return 0.9
    }
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
        backgroundColor: colorSchema.backColor ?? buttonBackgroundColor(for: action, isPressed: isPressed),
        foregroundColor: colorSchema.candidateTextColor ?? buttonForegroundColor(for: action, isPressed: isPressed),
        font: buttonFont(for: action),
        cornerRadius: buttonCornerRadius(for: action),
        border: KeyboardButtonBorderStyle(color: colorSchema.borderColor ?? .clearInteractable, size: 1),
        shadow: buttonShadowStyle(for: action)
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
