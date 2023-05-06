import KeyboardKit
import SwiftUI

extension KeyboardType {
  /**
   The keyboard type's standard button text.
   */
  public func hamsterButtonText(for context: KeyboardContext) -> String? {
    switch self {
    case .alphabetic: return KKL10n.keyboardTypeAlphabetic.hamsterText(for: context)
    case .numeric: return KKL10n.keyboardTypeNumeric.hamsterText(for: context)
    case .symbolic: return KKL10n.keyboardTypeSymbolic.hamsterText(for: context)
    case .custom(let name):
      if let customKeyboard = KeyboardConstant.keyboardType(rawValue: name) {
        return customKeyboard.buttonName
      }
      return nil
    default: return nil
    }
  }
}
