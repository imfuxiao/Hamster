import CoreGraphics
import KeyboardKit
import SwiftUI

public extension KeyboardAction {
  /**
   The action's standard button image.
   */
  func hamsterButtonImage(for context: KeyboardContext) -> Image? {
    switch self {
    case .image(_, _, let imageName):
      if !imageName.isEmpty {
        return Image(imageName)
      }
      return nil
    default: return nil
    }
  }

  /**
   The action's standard button text.
   */
  func hamsterButtonText(for context: KeyboardContext) -> String? {
    switch self {
    case .character(let char): return char
    case .emoji(let emoji): return emoji.char
    case .emojiCategory(let cat): return cat.fallbackDisplayEmoji.char
    case .keyboardType(let type): return type.hamsterButtonText(for: context)
    case .nextLocale: return context.locale.languageCode?.uppercased()
    case .primary(let type): return type.hamsterButtonText(for: context.locale)
    case .space:
      // TODO: 空格文字显示逻辑放在页面控制
      return nil
//      if context.locale.identifier == "zh-Hans" {
//        return "空格"
//      }
//      return KKL10n.space.hamsterText(for: context)
    // 自定义按键显示文字
    case .custom(let name):
      return KKL10n.hamsterText(forKey: name, locale: context.locale)
    default: return nil
    }
  }
}
