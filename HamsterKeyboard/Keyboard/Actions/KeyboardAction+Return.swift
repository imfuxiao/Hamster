import KeyboardKit
import SwiftUI

public extension KeyboardReturnKeyType {
  /**
   The standard button to text for a certain locale.
   */
  func hamsterButtonText(for locale: Locale) -> String? {
    switch self {
//    case .custom(let title):
//      // workaround until https://github.com/KeyboardKit/KeyboardKit/issues/432 resolved
//      if title == "send" {
//        return KKL10n.hamsterText(forKey: title, locale: locale)
//      }
//      return title
    case .custom(let title): return title
    case .done: return KKL10n.done.hamsterText(for: locale)
    case .go: return KKL10n.go.hamsterText(for: locale)
    case .join: return KKL10n.join.hamsterText(for: locale)
    case .newLine: return nil
      case .next: return KKL10n.next.hamsterText(for: locale)
    case .return: return KKL10n.return.hamsterText(for: locale)
    case .ok: return KKL10n.ok.hamsterText(for: locale)
    case .search: return KKL10n.search.hamsterText(for: locale)
      case .send: return KKL10n.send.hamsterText(for: locale)
    }
  }
}
