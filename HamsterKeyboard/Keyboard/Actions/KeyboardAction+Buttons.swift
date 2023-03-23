import CoreGraphics
import KeyboardKit
import SwiftUI

public extension KeyboardAction {
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
      return KKL10n.space.hamsterText(for: context)
    // 自定义按键显示文字
    case .custom(let name):
      return name
    default: return nil
    }
  }
}
