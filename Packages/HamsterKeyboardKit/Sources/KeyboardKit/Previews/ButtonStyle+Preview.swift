//
//  ButtonStyle+Preview.swift
//
//
//  Created by morse on 2023/8/10.
//
import UIKit

extension KeyboardButtonBorderStyle {
  /**
   This internal style is only used in previews.

   这种内部样式只用于预览。
   */
  static let previewStyle1 = KeyboardButtonBorderStyle(
    color: .red,
    size: 3
  )

  /**
   This internal style is only used in previews.

   这种内部样式只用于预览。
   */
  static let previewStyle2 = KeyboardButtonBorderStyle(
    color: .blue,
    size: 5
  )
}

extension KeyboardButtonShadowStyle {
  /**
   This internal style is only used in previews.

   这种内部样式只用于预览。
   */
  static let previewStyle1 = KeyboardButtonShadowStyle(
    color: .blue,
    size: 4
  )

  /**
   This internal style is only used in previews.

   这种内部样式只用于预览。
   */
  static let previewStyle2 = KeyboardButtonShadowStyle(
    color: .green,
    size: 8
  )
}

extension KeyboardButtonStyle {
  /**
   This internal style is only used in previews.

   这种内部样式只用于预览。
   */
  static let preview1 = KeyboardButtonStyle(
    backgroundColor: .yellow,
    foregroundColor: .white,
    font: UIFont.preferredFont(forTextStyle: .body),
    cornerRadius: 20,
    border: .previewStyle1,
    shadow: .previewStyle1
  )

  /**
   This internal style is only used in previews.

   这种内部样式只用于预览。
   */
  static let preview2 = KeyboardButtonStyle(
    backgroundColor: .purple,
    foregroundColor: .yellow,
    font: UIFont.preferredFont(forTextStyle: .headline),
    cornerRadius: 10,
    border: .previewStyle2,
    shadow: .previewStyle2
  )
}
