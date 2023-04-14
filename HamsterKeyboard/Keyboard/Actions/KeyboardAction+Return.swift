import KeyboardKit
import SwiftUI

extension KeyboardAction.ReturnType {
  /**
   The standard button to text for a certain locale.
   */
  public func hamsterButtonText(for locale: Locale) -> String? {
//    if locale.identifier == "zh-Hans" {
//      return chineseReturnText()
//    }
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

  func chineseReturnText() -> String? {
    switch self {
    case .done: return "完成"
    case .go: return "前往"
    case .join: return "加入"
    case .newLine: return nil
    case .return: return "换行"
    case .ok: return "确定"
    case .search: return "搜索"
    case .custom(let title): return title
    }
  }
}
