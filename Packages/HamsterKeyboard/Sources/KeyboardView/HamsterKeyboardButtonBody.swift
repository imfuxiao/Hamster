//
//  HamsterKeyboardButtonBody.swift
//  Hamster
//
//  Created by morse on 2023/5/26.
//

import KeyboardKit
import SwiftUI

struct HamsterKeyboardButtonBody: View {
  /**
   Create a system keyboard button body view.

   - Parameters:
     - style: The button style to apply.
     - isPressed: Whether or not the button is pressed, by default `false`.
   */
  public init(
    style: KeyboardButtonStyle,
    isPressed: Bool = false
  ) {
    self.style = style
    self.isPressed = isPressed
  }

  private let style: KeyboardButtonStyle
  private let isPressed: Bool

  @EnvironmentObject
  var keyboardContext: KeyboardContext

  @EnvironmentObject
  var appSettings: HamsterAppSettings

  public var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .strokeBorder(borderColor, lineWidth: borderLineWidth)
      .background(backgroundColor)
      .overlay(isPressed ? style.pressedOverlayColor : .clear)
      .cornerRadius(cornerRadius)
      .overlay(SystemKeyboardButtonShadow(style: style))
  }
}

extension HamsterKeyboardButtonBody {
  var backgroundColor: Color {
    style.backgroundColor ?? .clear
  }

  var borderColor: Color {
    style.border?.color ?? .clear
  }

  var borderLineWidth: CGFloat {
    style.border?.size ?? 0
  }

  var cornerRadius: CGFloat {
    style.cornerRadius ?? 0
  }
}

extension KeyboardButtonBorderStyle {
  /**
   This internal style is only used in previews.
   */
  static let previewStyle1 = KeyboardButtonBorderStyle(
    color: .red,
    size: 3
  )

  /**
   This internal style is only used in previews.
   */
  static let previewStyle2 = KeyboardButtonBorderStyle(
    color: .blue,
    size: 5
  )
}

extension KeyboardButtonShadowStyle {
  /**
   This internal style is only used in previews.
   */
  static let previewStyle1 = KeyboardButtonShadowStyle(
    color: .blue,
    size: 4
  )

  /**
   This internal style is only used in previews.
   */
  static let previewStyle2 = KeyboardButtonShadowStyle(
    color: .green,
    size: 8
  )
}

extension KeyboardButtonStyle {
  /**
   This internal style is only used in previews.
   */
  static let preview1 = KeyboardButtonStyle(
    backgroundColor: .yellow,
    foregroundColor: .white,
    font: .body,
    cornerRadius: 20,
    border: KeyboardButtonBorderStyle.previewStyle1,
    shadow: KeyboardButtonShadowStyle.previewStyle1
  )

  /**
   This internal style is only used in previews.
   */
  static let preview2 = KeyboardButtonStyle(
    backgroundColor: .purple,
    foregroundColor: .yellow,
    font: .headline,
    cornerRadius: 10,
    border: KeyboardButtonBorderStyle.previewStyle2,
    shadow: KeyboardButtonShadowStyle.previewStyle2
  )
}

struct HamsterKeyboardButtonBody_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      HamsterKeyboardButtonBody(style: KeyboardButtonStyle.preview1)
      HamsterKeyboardButtonBody(style: KeyboardButtonStyle.preview2)
    }
    .padding()
    .background(Color.gray)
    .cornerRadius(10)
    .environment(\.sizeCategory, .extraExtraLarge)
  }
}
