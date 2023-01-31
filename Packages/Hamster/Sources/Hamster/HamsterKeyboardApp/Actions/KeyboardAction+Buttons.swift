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
    case .return: return KKL10n.return.hamsterText(for: context)
    case .space: return KKL10n.space.hamsterText(for: context)
    default: return nil
    }
  }
}
