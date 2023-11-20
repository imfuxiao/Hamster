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
    case .email: return HamsterUIImage.shared.keyboardEmail
    case .emojis: return HamsterUIImage.shared.keyboardEmoji
    case .images: return HamsterUIImage.shared.keyboardImages
    case .alphabetic: return HamsterUIImage.shared.keyboardStateChinese
    case .chinese: return HamsterUIImage.shared.keyboardStateEnglish
    default: return nil
    }
  }

  var chineseImage: UIImage {
    HamsterUIImage.shared.keyboardStateChinese
  }

  var englishImage: UIImage {
    HamsterUIImage.shared.keyboardStateEnglish
  }

  /**
   The keyboard type's standard button text.

   键盘类型的标准按钮文本。
   */
  func standardButtonText(for context: KeyboardContext) -> String? {
    switch self {
    case .chinese, .chineseNineGrid: return "中"
    case .classifySymbolic, .classifySymbolicOfLight: return "#+="
    case .alphabetic: return "ABC"
    case .numeric: return "123"
    case .numericNineGrid: return "123"
    case .chineseNumeric: return "123"
    case .symbolic: return "#+="
    case .chineseSymbolic: return "#+="
    case .custom: return "中"
    default: return nil
//    case .alphabetic: return KKL10n.keyboardTypeAlphabetic.text(for: context)
//    case .numeric: return KKL10n.keyboardTypeNumeric.text(for: context)
//    case .symbolic: return KKL10n.keyboardTypeSymbolic.text(for: context)
    }
  }
}
