//
//  KeyboardType+Button.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-09.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

public extension KeyboardType {
  /**
   The keyboard type's standard button image.

   键盘类型的标准按键图像。
   */
  var standardButtonImage: UIImage? {
    switch self {
    case .email: return .keyboardEmail
    case .emojis: return .keyboardEmoji
    case .images: return .keyboardImages
    default: return nil
    }
  }

  /**
   The keyboard type's standard button text.

   键盘类型的标准按钮文本。
   */
  func standardButtonText(for context: KeyboardContext) -> String? {
    switch self {
    case .alphabetic: return KKL10n.keyboardTypeAlphabetic.text(for: context)
    case .numeric: return KKL10n.keyboardTypeNumeric.text(for: context)
    case .symbolic: return KKL10n.keyboardTypeSymbolic.text(for: context)
    default: return nil
    }
  }
}