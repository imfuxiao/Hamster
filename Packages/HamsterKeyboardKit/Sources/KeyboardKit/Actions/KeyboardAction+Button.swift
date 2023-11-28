//
//  KeyboardAction+Button.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-07-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics
import UIKit

public extension KeyboardAction {
  /**
   The action's standard button image.

   该操作的标准按钮图像。
   */
  func standardButtonImage(for context: KeyboardContext) -> UIImage? {
    // if let image = standardButtonTextImageReplacement(for: context) { return image }
    switch self {
    case .backspace: return HamsterUIImage.shared.keyboardBackspace
    case .command: return HamsterUIImage.shared.keyboardCommand
    case .control: return HamsterUIImage.shared.keyboardControl
    case .dictation: return HamsterUIImage.shared.keyboardDictation
    case .dismissKeyboard: return HamsterUIImage.shared.keyboardDismiss
    case .image(_, let imageName, _): return UIImage(named: imageName)
    case .keyboardType(let type):
      if context.keyboardType.isNumber || context.keyboardType.isSymbol {
        return nil
      }
      return type.standardButtonImage
    case .moveCursorBackward: return HamsterUIImage.shared.keyboardLeft
    case .moveCursorForward: return HamsterUIImage.shared.keyboardRight
    case .nextKeyboard: return HamsterUIImage.shared.keyboardGlobe
    case .option: return HamsterUIImage.shared.keyboardOption
//    case .primary(let type): return type.standardButtonImage(for: context.locale)
    case .settings: return HamsterUIImage.shared.keyboardSettings
    case .shift(let currentCasing):
      return currentCasing.standardButtonImage
    case .systemImage(_, let imageName, _): return UIImage(systemName: imageName)
    case .systemSettings: return HamsterUIImage.shared.keyboardSettings
    case .tab: return HamsterUIImage.shared.keyboardTab
    default: return nil
    }
  }

  /**
   The action's standard button text.

   该操作的标准按钮文本。
   */
  func standardButtonText(for context: KeyboardContext) -> String? {
    switch self {
    case .character(let char), .characterOfDark(let char):
      // 中文输入法显示大写
      if context.keyboardType.isChinese, context.showUppercasedCharacterOnChineseKeyboard {
        return char.uppercased()
      }
      return char
    case .emoji(let emoji): return emoji.char
    case .emojiCategory(let cat): return cat.fallbackDisplayEmoji.char
    case .keyboardType(let type): return type.standardButtonText(for: context)
//    case .nextLocale: return context.locale.languageCode?.uppercased()
    case .primary(let type): return type.standardButtonText()
    case .space:
      // return KKL10n.space.text(for: context)
      return "空格"
    case .returnLastKeyboard: return "返回"
    case .symbol(let symbol), .symbolOfDark(let symbol): return symbol.char
    case .chineseNineGrid(let symbol): return symbol.char
    case .cleanSpellingArea: return "重输"
    case .delimiter: return "分词"
    default: return nil
    }
  }

  /**
   The action's standard button text image replacement, if
   the text represents an image asset.

   如果该操作的文本代表图像资源，则该操作的文本使用图像替换。
   */
  func standardButtonTextImageReplacement(for context: KeyboardContext) -> UIImage? {
    switch standardButtonText(for: context) {
//    case "↵", "↳": return HamsterUIImage.shared.keyboardNewline(for: context.locale)
    default: return nil
    }
  }
}
