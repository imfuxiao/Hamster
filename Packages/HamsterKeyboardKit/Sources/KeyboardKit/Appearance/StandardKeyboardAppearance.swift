//
//  StandardKeyboardAppearance.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-10.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics
import UIKit

/**
 This standard appearance returns styles that replicates the
 look of a native system keyboard.

 该标准外观返回的样式与本地系统键盘的外观相同。

 You can inherit this class and override any open properties
 and functions to customize the appearance. For instance, to
 change the background color of inpout keys only, you can do
 it like this:

 您可以继承该类，并覆盖任何 open 的属性和函数来定制外观。例如，如果只想更改按键的背景颜色，可以这样做：

 ```swift
 class MyAppearance: StandardKeyboardAppearance {

     override func buttonStyle(
         for action: KeyboardAction,
         isPressed: Bool
     ) -> KeyboardButtonStyle {
         let style = super.buttonStyle(for: action, isPressed: isPressed)
         if !action.isInputAction { return style }
         style.backgroundColor = .red
         return style
     }
 }
 ```

 All buttons will be affected if you only return a new style.
 Sometimes that is what you want, but most often perhaps not.

 如果只返回新样式，所有按钮都会受到影响。有时这是你想要的，但大多数情况下可能不是。
 */
open class StandardKeyboardAppearance: KeyboardAppearance {
  /// The keyboard context to use.
  ///
  /// 要使用的键盘上下文。
  public let keyboardContext: KeyboardContext

  // MARK: - Keyboard 键盘样式

  /// The background style to apply to the entire keyboard.
  ///
  /// 应用于整个键盘的背景样式。
  open var backgroundStyle: KeyboardBackgroundStyle {
    .standard
  }

  /// The foreground color to apply to the entire keyboard.
  ///
  /// 应用于整个键盘的前景色。
  open var foregroundColor: UIColor? {
    nil
  }

  /// The edge insets to apply to the entire keyboard.
  ///
  /// 应用于整个键盘的边缘嵌入。
  open var keyboardEdgeInsets: UIEdgeInsets {
    switch keyboardContext.deviceType {
    case .pad: return UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
    case .phone:
      if keyboardContext.screenSize.isEqual(to: .iPhoneProMaxScreenPortrait, withTolerance: 10) {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      } else {
        return UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 0)
      }
    default: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
  }

  /// The keyboard layout configuration to use.
  ///
  /// 要使用的键盘布局配置。
  open var keyboardLayoutConfiguration: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Buttons

  /// The button image to use for a certain action, if any.
  ///
  /// 用于特定操作的按钮图像（如果有）。
  open func buttonImage(for action: KeyboardAction) -> UIImage? {
    action.standardButtonImage(for: keyboardContext)
  }

  /// The content scale factor to use for a certain action.
  ///
  /// 用于特定操作的图像比例因子。
  open func buttonImageScaleFactor(for action: KeyboardAction) -> CGFloat {
    switch keyboardContext.deviceType {
    case .pad: return 1.2
    default: return 1
    }
  }

  /// The button style to use for a certain action.
  ///
  /// 在给定的 `isPressed` 状态下，用于特定 `action` 的按键样式。
  open func buttonStyle(for action: KeyboardAction, isPressed: Bool) -> KeyboardButtonStyle {
    // 开启键盘配色
    if let keyboardColor = keyboardContext.keyboardColor {
      return KeyboardButtonStyle(
        backgroundColor: isPressed ? buttonBackgroundColor(for: action, isPressed: isPressed) : keyboardColor.backColor,
        foregroundColor: isPressed ? buttonForegroundColor(for: action, isPressed: isPressed) : keyboardColor.candidateTextColor,
        font: buttonFont(for: action),
        cornerRadius: buttonCornerRadius(for: action),
        border: buttonBorderStyle(for: action),
        shadow: buttonShadowStyle(for: action))
    }

    return KeyboardButtonStyle(
      backgroundColor: buttonBackgroundColor(for: action, isPressed: isPressed),
      foregroundColor: buttonForegroundColor(for: action, isPressed: isPressed),
      font: buttonFont(for: action),
      cornerRadius: buttonCornerRadius(for: action),
      border: buttonBorderStyle(for: action),
      shadow: buttonShadowStyle(for: action))
  }

  /// The button text to use for a certain action, if any.
  ///
  /// 用于特定操作的按钮文本（如果有）。
  open func buttonText(for action: KeyboardAction) -> String? {
    action.standardButtonText(for: keyboardContext)
  }

  // MARK: - Callouts

  /**
   The callout style to apply to action and input callouts.

   应用于操作和输入呼出的呼出样式。
   */
  open var calloutStyle: KeyboardCalloutStyle {
    var style = KeyboardCalloutStyle.standard
    let button = buttonStyle(for: .character(""), isPressed: false)
    style.buttonCornerRadius = button.cornerRadius ?? 5
    return style
  }

  /// The style to apply to ``ActionCallout`` views.
  ///
  /// 应用于 ``ActionCallout`` 视图的样式。
  open var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = KeyboardActionCalloutStyle.standard
    style.callout = calloutStyle
    return style
  }

  /// The style to apply to ``InputCallout`` views.
  ///
  /// 应用于 ``InputCallout`` 视图的样式。
  open var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = KeyboardInputCalloutStyle.standard
    style.callout = calloutStyle
    return style
  }

  // MARK: - Autocomplete

  /// The style to apply to ``AutocompleteToolbar`` views.
  ///
  /// 应用于 ``AutocompleteToolbar`` 视图的样式。
  public var autocompleteToolbarStyle: AutocompleteToolbarStyle {
    return .standard
  }

  // MARK: - initialisation

  /**
   Create a standard keyboard appearance intance.

   - Parameters:
     - keyboardContext: The keyboard context to use.
   */
  public init(keyboardContext: KeyboardContext) {
    self.keyboardContext = keyboardContext
  }

  // MARK: - Overridable Button Style Components 可覆盖的按钮样式组件

  /// The background color to use for a certain action.
  ///
  /// 根据给定 `isPressed` 状态， 用于特定操作的背景颜色。
  open func buttonBackgroundColor(for action: KeyboardAction, isPressed: Bool) -> UIColor {
    return action.buttonBackgroundColor(for: keyboardContext, isPressed: isPressed)
  }

  /// The border style to use for a certain action.
  ///
  /// 用于特定操作的边框样式。
  open func buttonBorderStyle(for action: KeyboardAction) -> KeyboardButtonBorderStyle {
    switch action {
    case .emoji, .emojiCategory, .none: return .noBorder
    default:
      if let keyboardColor = keyboardContext.keyboardColor {
        return KeyboardButtonBorderStyle(color: keyboardColor.borderColor, size: 1)
      }
      return .standard
    }
  }

  /// The corner radius to use for a certain action.
  ///
  /// 用于特定操作的圆角半径。
  open func buttonCornerRadius(for action: KeyboardAction) -> CGFloat {
    keyboardLayoutConfiguration.buttonCornerRadius
  }

  /// The font to use for a certain action.
  ///
  /// 用于特定操作的字体。
  open func buttonFont(for action: KeyboardAction) -> KeyboardFont {
    let size = buttonFontSize(for: action)
    let font = KeyboardFont.system(size: size)
    guard let weight = buttonFontWeight(for: action) else { return font }
    return font.weight(weight)
  }

  /// The font size to use for a certain action.
  ///
  /// 用于特定操作的字体大小。
  open func buttonFontSize(for action: KeyboardAction) -> CGFloat {
    if let override = buttonFontSizePadOverride(for: action) { return override }
    if buttonImage(for: action) != nil { return 20 }
    if let override = buttonFontSizeActionOverride(for: action) { return override }
    if action == .returnLastKeyboard || action == .cleanSpellingArea {
      return 16
    }
    let text = buttonText(for: action) ?? ""
    if action.isInputAction && text.isLowercased { return 26 }
    if action.isSystemAction || action.isPrimaryAction { return 16 }
    return 23
  }

  /// The font size to override for a certain action.
  ///
  /// 用于特定操作需要覆盖的字体大小。
  func buttonFontSizeActionOverride(for action: KeyboardAction) -> CGFloat? {
    switch action {
    case .keyboardType(let type): return buttonFontSize(for: type)
    case .space: return 16
    default: return nil
    }
  }

  /// The font size to override for a certain iPad action.
  ///
  /// 在 iPad 上执行特定操作时需要覆盖的字体大小。
  func buttonFontSizePadOverride(for action: KeyboardAction) -> CGFloat? {
    guard keyboardContext.deviceType == .pad else { return nil }
    let isLandscape = keyboardContext.interfaceOrientation.isLandscape
    guard isLandscape else { return nil }
    if action.isAlphabeticKeyboardTypeAction { return 22 }
    if action.isKeyboardTypeAction(.numeric) { return 22 }
    if action.isKeyboardTypeAction(.symbolic) { return 20 }
    return nil
  }

  /// The font size to use for a certain keyboard type.
  ///
  /// 用于特定键盘类型的字体大小。
  open func buttonFontSize(for keyboardType: KeyboardType) -> CGFloat {
    switch keyboardType {
    case .alphabetic: return 15
    case .numeric: return 16
    case .symbolic: return 14
    default: return 14
    }
  }

  /// The font weight to use for a certain action.
  ///
  /// 用于特定操作的字体粗细。
  open func buttonFontWeight(for action: KeyboardAction) -> KeyboardFontWeight? {
    switch action {
    case .backspace: return .regular
    case .character(let char): return char.isLowercased ? .light : nil
    default: return buttonImage(for: action) != nil ? .light : nil
    }
  }

  /// The foreground color to use for a certain action.
  ///
  /// 用于特定操作的按键前景色。
  open func buttonForegroundColor(for action: KeyboardAction, isPressed: Bool) -> UIColor {
    action.buttonForegroundColor(for: keyboardContext, isPressed: isPressed)
  }

  /// The shadow style to use for a certain action.
  ///
  /// 用于特定操作的按键阴影样式。
  open func buttonShadowStyle(for action: KeyboardAction) -> KeyboardButtonShadowStyle {
    switch action {
    case .characterMargin: return .noShadow
    case .emoji, .emojiCategory: return .noShadow
    case .none: return .noShadow
    default: return .standard
    }
  }
}

extension KeyboardAction {
  /// 所有状态的按键背景颜色
  var buttonBackgroundColorForAllStates: UIColor? {
    switch self {
    case .none: return .clear
    case .characterMargin: return .clearInteractable
    case .emoji: return .clearInteractable
    case .emojiCategory: return .clearInteractable
    default: return nil
    }
  }

  /// 给定 `isPressed` 状态下，根据 `context`，获取按键背景色
  func buttonBackgroundColor(for context: KeyboardContext, isPressed: Bool = false) -> UIColor {
    if let color = buttonBackgroundColorForAllStates { return color }
    return isPressed ?
      buttonBackgroundColorForPressedState(for: context) :
      buttonBackgroundColorForIdleState(for: context)
  }

  /// 按键空闲状态的背景颜色
  func buttonBackgroundColorForIdleState(for context: KeyboardContext) -> UIColor {
    if isUppercasedShiftAction { return buttonBackgroundColorForPressedState(for: context) }
    if isSystemAction || isSymbolAction || isCleanSpellingArea { return .standardDarkButtonBackground(for: context) }
    if isPrimaryAction { return UIColor.systemBlue }
    if isUppercasedShiftAction { return .standardButtonBackground(for: context) }
    return .standardButtonBackground(for: context)
  }

  /// 按键按下状态的背景颜色
  func buttonBackgroundColorForPressedState(for context: KeyboardContext) -> UIColor {
    if isSystemAction || isSymbolAction || isCleanSpellingArea { return context.hasDarkColorScheme ? .standardButtonBackground(for: context) : .white }
    if isPrimaryAction { return context.hasDarkColorScheme ? .standardDarkButtonBackground(for: context) : .white }
    if isUppercasedShiftAction { return .standardDarkButtonBackground(for: context) }
    return .standardDarkButtonBackground(for: context)
  }

  /// 全部状态下按键的前景色
  var buttonForegroundColorForAllStates: UIColor? {
    switch self {
    case .none: return .clear
    case .characterMargin: return .clearInteractable
    default: return nil
    }
  }

  /// 根据 `isPressed` 状态，`context` 获取按键前景色
  func buttonForegroundColor(for context: KeyboardContext, isPressed: Bool = false) -> UIColor {
    if let color = buttonForegroundColorForAllStates { return color }
    return isPressed ?
      buttonForegroundColorForPressedState(for: context) :
      buttonForegroundColorForIdleState(for: context)
  }

  /// 空闲状态下按键的前景色
  func buttonForegroundColorForIdleState(for context: KeyboardContext) -> UIColor {
    let standard = UIColor.standardButtonForeground(for: context)
    if isSystemAction { return standard }
    if isPrimaryAction { return .white }
    return standard
  }

  /// 按下状态下按键的前景色
  func buttonForegroundColorForPressedState(for context: KeyboardContext) -> UIColor {
    let standard = UIColor.standardButtonForeground(for: context)
    if isSystemAction { return standard }
    if isPrimaryAction { return context.hasDarkColorScheme ? .white : standard }
    return standard
  }
}
