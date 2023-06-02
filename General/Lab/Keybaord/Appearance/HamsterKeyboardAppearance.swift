//
//  StandardKeyboardAppearance.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-10.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Combine
import CoreGraphics
import KeyboardKit
import SwiftUI

/**
 This standard appearance returns styles that replicates the
 look of a native system keyboard.

 You can inherit this class and override any open properties
 and functions to customize the appearance. For instance, to
 change the background color of inpout keys only, you can do
 it like this:

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
 */
open class HamsterKeyboardAppearance: KeyboardAppearance {
  /**
   Create a standard keyboard appearance intance.

   - Parameters:
   - keyboardContext: The keyboard context to use.
   */
  public init(keyboardContext: KeyboardContext, rimeContext: RimeContext, appSettings: HamsterAppSettings) {
    self.keyboardContext = keyboardContext
    self.appSettings = appSettings
    self.rimeContext = rimeContext
    self.buttonExtendCharacter = appSettings.buttonExtendCharacter

    appSettings.$rimeColorSchema
      .receive(on: RunLoop.main)
      .sink { [unowned self] _ in
        self.hamsterColorSchema = getCurrentColorSchema()
      }
      .store(in: &cancelable)
  }

  public let appSettings: HamsterAppSettings
  public let rimeContext: RimeContext

  public var hamsterColorSchema: HamsterColorSchema?
  private var cancelable = Set<AnyCancellable>()

  /**
   The keyboard context to use.
   */
  public let keyboardContext: KeyboardContext

  // 滑动符号映射显示
  public var buttonExtendCharacter: [String: [String]]

  // MARK: - Keyboard

  /**
   The background color to apply to the keyboard.
   */
  public var backgroundStyle: KeyboardBackgroundStyle {
    if let hamsterColorSchema = hamsterColorSchema {
      return KeyboardBackgroundStyle(.color(hamsterColorSchema.backColor))
    }
    return .standard
  }

  /**
   The edge insets to apply to the entire keyboard.
   */
  open var keyboardEdgeInsets: EdgeInsets {
    switch keyboardContext.deviceType {
    case .pad: return EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
    case .phone: return EdgeInsets(top: 0, leading: 0, bottom: -2, trailing: 0)
    default: return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
  }

  /**
   The keyboard layout configuration to use.
   */
  open var keyboardLayoutConfiguration: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Buttons

  // hamster启用的配色方案
  func getCurrentColorSchema() -> HamsterColorSchema? {
    guard appSettings.enableRimeColorSchema else { return nil }
    guard !appSettings.rimeColorSchema.isEmpty else { return nil }
    guard let colorSchema = appSettings.rimeTotalColorSchemas.first(
      where: { $0.schemaName == appSettings.rimeColorSchema }
    ) else { return nil }
    return HamsterColorSchema(schema: colorSchema)
  }

  /**
   The button image to use for a certain `action`, if any.
   */
  open func buttonImage(for action: KeyboardAction) -> Image? {
    if let image = action.hamsterButtonImage(for: keyboardContext, rimeContext: rimeContext) {
      return image
    }
    return action.standardButtonImage(for: keyboardContext)
  }

  /**
   The scale factor to apply to the button content, if any.
   */
  open func buttonImageScaleFactor(for action: KeyboardAction) -> CGFloat {
    switch keyboardContext.deviceType {
    case .pad: return 1.2
    default: return 1
    }
  }

  /**
   The button style to use for a certain `action`, given a
   certain `isPressed` state.
   */
  open func buttonStyle(for action: KeyboardAction, isPressed: Bool) -> KeyboardButtonStyle {
    // TODO: 根据 squirrel 颜色方案动态变更
    if let hamsterColorSchema = hamsterColorSchema {
      return KeyboardButtonStyle(
        backgroundColor: hamsterColorSchema.backColor == .clear ? buttonBackgroundColor(for: action, isPressed: isPressed) : hamsterColorSchema.backColor,
        foregroundColor: hamsterColorSchema.candidateTextColor == .clear ? buttonForegroundColor(for: action, isPressed: isPressed) : hamsterColorSchema.candidateTextColor,
        font: buttonFont(for: action),
        cornerRadius: buttonCornerRadius(for: action),
        border: KeyboardButtonBorderStyle(color: hamsterColorSchema.borderColor, size: 1),
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

  /**
   The button text to use for a certain `action`, if any.
   */
  open func buttonText(for action: KeyboardAction) -> String? {
//    action.standardButtonText(for: keyboardContext)
    action.hamsterButtonText(for: keyboardContext)
  }

  // MARK: - Callouts

  /**
   The callout style to apply to action and input callouts.
   */
  open var calloutStyle: KeyboardCalloutStyle {
//    var style = KeyboardCalloutStyle.standard
    var style = KeyboardCalloutStyle.hamsterStandard
    let button = buttonStyle(for: .character(""), isPressed: false)
    style.buttonCornerRadius = button.cornerRadius ?? 5
    return style
  }

  /**
   The style to apply when presenting an ``ActionCallout``.
   */
  open var actionCalloutStyle: KeyboardActionCalloutStyle {
//    var style = KeyboardActionCalloutStyle.standard
    var style = KeyboardActionCalloutStyle.hamsterStandard
    style.callout = calloutStyle
    return style
  }

  /**
   The style to apply when presenting an ``InputCallout``.
   */
  open var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = KeyboardInputCalloutStyle.standard
    style.callout = calloutStyle
    return style
  }

  // MARK: - Autocomplete

  public var autocompleteToolbarStyle: AutocompleteToolbarStyle {
//    return .standard
    //    return .standard
    return .init(
      item: AutocompleteToolbarItemStyle(
        titleFont: .system(
          size: CGFloat(appSettings.rimeCandidateTitleFontSize)
        ),
        titleColor: .primary,
        subtitleFont: .system(
          size: CGFloat(appSettings.rimeCandidateCommentFontSize)
        )
      )
    )
  }

  // MARK: - Overridable Button Style Components

  /**
   The button background color to use for a certain action.
   */
  open func buttonBackgroundColor(for action: KeyboardAction, isPressed: Bool) -> Color {
    let fullOpacity = keyboardContext.hasDarkColorScheme || isPressed
    return action.buttonBackgroundColor(for: keyboardContext, isPressed: isPressed)
      .opacity(fullOpacity ? 1 : 0.95)
  }

  /**
   The button border style to use for a certain action.
   */
  open func buttonBorderStyle(for action: KeyboardAction) -> KeyboardButtonBorderStyle {
    switch action {
    case .emoji, .emojiCategory, .none: return .noBorder
    default: return .standard
    }
  }

  /**
   The button corner radius to use for a certain action.
   */
  open func buttonCornerRadius(for action: KeyboardAction) -> CGFloat {
    keyboardLayoutConfiguration.buttonCornerRadius
  }

  /**
   The button font to use for a certain action.
   */
  open func buttonFont(for action: KeyboardAction) -> KeyboardFont {
    let size = buttonFontSize(for: action)
    let font = KeyboardFont.system(size: size)
    guard let weight = buttonFontWeight(for: action) else { return font }
    return font.weight(weight)
  }

  /**
   The button font size to use for a certain action.
   */
  open func buttonFontSize(for action: KeyboardAction) -> CGFloat {
    if let override = buttonFontSizePadOverride(for: action) { return override }
    if buttonImage(for: action) != nil { return 20 }
    if let override = buttonFontSizeActionOverride(for: action) { return override }
    let text = buttonText(for: action) ?? ""
    if action.isHamsterInputAction && text.isLowercased { return 26 }
    if action.isSystemAction || action.isPrimaryAction { return 16 }
    return 23
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
   The button font size to force override for iPad devices.
   */
  func buttonFontSizePadOverride(for action: KeyboardAction) -> CGFloat? {
    guard keyboardContext.deviceType == .pad else { return nil }
    let isLandscape = keyboardContext.interfaceOrientation.isLandscape
    guard isLandscape else { return nil }
    if action.isAlphabeticKeyboardTypeAction || action.isHamsterInputAction { return 22 }
    if action.isKeyboardTypeAction(.numeric) || action.isHamsterInputAction { return 22 }
    if action.isKeyboardTypeAction(.symbolic) { return 20 }
    return nil
  }

  /**
   The button font size to use for a certain keyboard type.
   */
  open func buttonFontSize(for keyboardType: KeyboardType) -> CGFloat {
    switch keyboardType {
    case .alphabetic: return 15
    case .numeric: return 16
    case .symbolic: return 14
    case .custom: return 16
    default: return 14
    }
  }

  /**
   The button font weight to use for a certain action.

   You can override this function to customize this single
   button style property.
   */
  open func buttonFontWeight(for action: KeyboardAction) -> KeyboardFontWeight? {
    if isGregorianAlpha { return .regular }
    switch action {
    case .backspace: return .regular
    case .character(let char): return char.isLowercased ? .light : nil
    default: return buttonImage(for: action) != nil ? .light : nil
    }
  }

  /**
   The button foreground color to use for a certain action.

   You can override this function to customize this single
   button style property.
   */
  open func buttonForegroundColor(for action: KeyboardAction, isPressed: Bool) -> Color {
    action.buttonForegroundColor(for: keyboardContext, isPressed: isPressed)
  }

  /**
   The button shadow style to use for a certain action.

   You can override this function to customize this single
   button style property.
   */
  open func buttonShadowStyle(for action: KeyboardAction) -> KeyboardButtonShadowStyle {
    switch action {
    case .characterMargin: return .noShadow
    case .emoji, .emojiCategory: return .noShadow
    case .none: return .noShadow
    default: return .standard
    }
  }
}

// MARK: - Internal, Testable Extensions

extension HamsterKeyboardAppearance {
  var isGregorianAlpha: Bool {
    keyboardContext.keyboardType.isAlphabetic && keyboardContext.locale.matches(.georgian)
  }
}

extension KeyboardAction {
  var buttonBackgroundColorForAllStates: Color? {
    switch self {
    case .none: return .clear
    case .characterMargin: return .clearInteractable
    case .emoji: return .clearInteractable
    case .emojiCategory: return .clearInteractable
    default: return nil
    }
  }

  func buttonBackgroundColor(for context: KeyboardContext, isPressed: Bool = false) -> Color {
    if let color = buttonBackgroundColorForAllStates { return color }
    return isPressed ?
      buttonBackgroundColorForPressedState(for: context) :
      buttonBackgroundColorForIdleState(for: context)
  }

  /// 空闲状态按钮背景色
  func buttonBackgroundColorForIdleState(for context: KeyboardContext) -> Color {
//    if isUppercasedShiftAction { return buttonBackgroundColorForPressedState(for: context) }
//    if isSystemAction { return .standardDarkButtonBackground(for: context) }
//    if isPrimaryAction { return .blue }
//    if isUppercasedShiftAction { return .standardButtonBackground(for: context) }
//    return .standardButtonBackground(for: context)
    if isUppercasedShiftAction { return buttonBackgroundColorForPressedState(for: context) }
    if isSystemAction { return .hamsterStandardDarkButtonBackground(for: context) }
    if isPrimaryAction { return .blue }
    if isUppercasedShiftAction { return .hamsterStandardButtonBackground(for: context) }
    return .hamsterStandardButtonBackground(for: context)
  }

  func buttonBackgroundColorForPressedState(for context: KeyboardContext) -> Color {
//    if isSystemAction { return context.hasDarkColorScheme ? .standardButtonBackground(for: context) : .white }
//    if isPrimaryAction { return context.hasDarkColorScheme ? .standardDarkButtonBackground(for: context) : .white }
//    if isUppercasedShiftAction { return .standardDarkButtonBackground(for: context) }
//    return .standardDarkButtonBackground(for: context)
    if isSystemAction { return context.hasDarkColorScheme ? .hamsterStandardButtonBackground(for: context) : .white }
    if isPrimaryAction { return context.hasDarkColorScheme ? .hamsterStandardDarkButtonBackground(for: context) : .white }
    if isUppercasedShiftAction { return .hamsterStandardDarkButtonBackground(for: context) }
    return .hamsterStandardDarkButtonBackground(for: context)
  }

  var buttonForegroundColorForAllStates: Color? {
    switch self {
    case .none: return .clear
    case .characterMargin: return .clearInteractable
    default: return nil
    }
  }

  func buttonForegroundColor(for context: KeyboardContext, isPressed: Bool = false) -> Color {
    if let color = buttonForegroundColorForAllStates { return color }
    return isPressed ?
      buttonForegroundColorForPressedState(for: context) :
      buttonForegroundColorForIdleState(for: context)
  }

  func buttonForegroundColorForIdleState(for context: KeyboardContext) -> Color {
    let standard = Color.standardButtonForeground(for: context)
    if isSystemAction { return standard }
    if isPrimaryAction { return .white }
    return standard
  }

  func buttonForegroundColorForPressedState(for context: KeyboardContext) -> Color {
    let standard = Color.standardButtonForeground(for: context)
    if isSystemAction { return standard }
    if isPrimaryAction { return context.hasDarkColorScheme ? .white : standard }
    return standard
  }

  func hamsterButtonBackgroundColor(for context: KeyboardContext, isPressed: Bool = false) -> Color {
    if let color = buttonBackgroundColorForAllStates { return color }
    return isPressed ?
      buttonBackgroundColorForPressedState(for: context) :
      buttonBackgroundColorForIdleState(for: context)
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

public struct HamsterColorSchema: Identifiable, Equatable, Codable {
  init(schema: ColorSchema) {
    self.backColor = schema.backColor.bgrColor ?? .clear
    self.borderColor = schema.borderColor.bgrColor ?? .clear
    self.textColor = schema.textColor.bgrColor ?? .clear
    self.hilitedTextColor = schema.hilitedTextColor.bgrColor ?? .clear
    self.hilitedBackColor = schema.hilitedBackColor.bgrColor ?? .clear
    self.hilitedCandidateTextColor = schema.hilitedCandidateTextColor.bgrColor ?? .clear
    self.hilitedCandidateBackColor = schema.hilitedCandidateBackColor.bgrColor ?? .clear
    self.hilitedCommentTextColor = schema.hilitedCommentTextColor.bgrColor ?? .clear
    self.candidateTextColor = schema.candidateTextColor.bgrColor ?? .clear
    self.commentTextColor = schema.commentTextColor.bgrColor ?? .clear
  }

  public var id = UUID()

  var backColor: Color // 窗体背景色 back_color
  var borderColor: Color // 边框颜色 border_color

  // MARK: 组字区域，对应键盘候选栏的用户输入字码

  var textColor: Color // 编码行文字颜色 24位色值，16进制，BGR顺序: text_color
  var hilitedTextColor: Color // 编码高亮: hilited_text_color
  var hilitedBackColor: Color // 编码背景高亮: hilited_back_color

  // 候选栏颜色
  var hilitedCandidateTextColor: Color // 首选文字颜色: hilited_candidate_text_color
  var hilitedCandidateBackColor: Color // 首选背景颜色: hilited_candidate_back_color
  // hilited_candidate_label_color 首选序号颜色
  var hilitedCommentTextColor: Color // 首选提示字母色: hilited_comment_text_color

  var candidateTextColor: Color // 次选文字色: candidate_text_color
  var commentTextColor: Color // 次选提示色: comment_text_color
  // label_color 次选序号颜色
}
