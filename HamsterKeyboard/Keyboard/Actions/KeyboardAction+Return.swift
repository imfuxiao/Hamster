import KeyboardKit
import SwiftUI

extension KeyboardAction.ReturnType {
  /**
     The standard button to text for a certain locale.
     */
  public func hamsterButtonText(for locale: Locale) -> String? {
    switch self {
    case .custom(let title): return title
    case .done: return KKL10n.done.hamsterText(for: locale)
    case .go: return KKL10n.go.hamsterText(for: locale)
    case .join: return KKL10n.join.hamsterText(for: locale)
    case .newLine: return nil
    case .return: return KKL10n.return.hamsterText(for: locale)
    case .ok: return KKL10n.ok.hamsterText(for: locale)
    case .search: return KKL10n.search.hamsterText(for: locale)
    }
  }
}
