import KeyboardKit
import SwiftUI

extension KeyboardType {
  /**
   The keyboard type's standard button text.
   */
  public func hamsterButtonText(for context: KeyboardContext) -> String? {
//    if context.locale.identifier == "zh-Hans" {
//      return chineseText()
//    }
    switch self {
    case .alphabetic: return KKL10n.keyboardTypeAlphabetic.hamsterText(for: context)
    case .numeric: return KKL10n.keyboardTypeNumeric.hamsterText(for: context)
    case .symbolic: return KKL10n.keyboardTypeSymbolic.hamsterText(for: context)

    default: return nil
    }
  }

  func chineseText() -> String? {
    switch self {
    case .alphabetic: return "ABC"
    case .numeric: return "123"
    case .symbolic: return "#+="
    case .custom(let name):
      let customKeyboard = KeyboardConstant.keyboardType(rawValue: name)
      return customKeyboard?.buttonName
    default:
      return nil
    }
  }
}
