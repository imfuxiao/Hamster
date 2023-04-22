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
   The edge insets to apply to the entire keyboard.
   */
  override var keyboardEdgeInsets: EdgeInsets {
    switch keyboardContext.deviceType {
    case .pad: return EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
    case .phone: return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    default: return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
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

  // TODO：自定义Button背景色
  override func buttonBackgroundColor(for action: KeyboardAction, isPressed: Bool) -> Color {
    // 数字九宫格键盘颜色一致
    if appSettings.enableNumberNineGrid && keyboardContext.keyboardType == .numeric {
      return .standardDarkButtonBackground
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

  /**
   The callout style to apply to action and input callouts.
   应用于Action和Input Callout的Callout样式。
   */
  override var calloutStyle: KeyboardCalloutStyle {
    var style = KeyboardCalloutStyle.hamsterStandard
    style.buttonCornerRadius = 5
    return style
  }

  override var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = KeyboardActionCalloutStyle.hamsterStandard
    style.callout = calloutStyle
    return style
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

extension KeyboardCalloutStyle {
  static var hamsterStandard = KeyboardCalloutStyle(
    backgroundColor: .standardButtonBackground,
    borderColor: Color.black.opacity(0.5),
    buttonCornerRadius: 5,
    buttonInset: CGSize(width: 5, height: 5),
    cornerRadius: 10,
    curveSize: CGSize(width: 8, height: 15),
    shadowColor: Color.black.opacity(0.1),
    shadowRadius: 5,
    textColor: .primary
  )
}

extension KeyboardActionCalloutStyle {
  static var hamsterStandard = KeyboardActionCalloutStyle(
    callout: KeyboardCalloutStyle.hamsterStandard,
    font: .system(size: 12),
    maxButtonSize: CGSize(width: 1000, height: 500),
    selectedBackgroundColor: .blue,
    selectedForegroundColor: .white,
    verticalOffset: nil,
    verticalTextPadding: 6
  )
}
