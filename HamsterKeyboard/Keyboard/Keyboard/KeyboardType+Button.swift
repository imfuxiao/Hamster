import KeyboardKit
import SwiftUI

public extension KeyboardType {
    /**
     The keyboard type's standard button text.
     */
    func hamsterButtonText(for context: KeyboardContext) -> String? {
        switch self {
        case .alphabetic: return KKL10n.keyboardTypeAlphabetic.hamsterText(for: context)
        case .numeric: return KKL10n.keyboardTypeNumeric.hamsterText(for: context)
        case .symbolic: return KKL10n.keyboardTypeSymbolic.hamsterText(for: context)
        default: return nil
        }
    }
}
