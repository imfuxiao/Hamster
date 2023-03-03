import Foundation
import KeyboardKit
import Plist
import SwiftUI

class HamsterStandardKeyboardLayoutProvider: StandardKeyboardLayoutProvider {
    /**
     The layout provider that is used for iPad devices.
     */
    lazy var hamsteriPadProvider = HamsteriPadKeyboardLayoutProvider(inputSetProvider: inputSetProvider)

    /**
     The layout provider that is used for iPhone devices.
     */
    lazy var hamsteriPhoneProvider = HamsteriPhoneKeyboardLayoutProvider(inputSetProvider: inputSetProvider)

    override func keyboardLayoutProvider(for context: KeyboardContext) -> KeyboardLayoutProvider {
        if let provider = localizedProviders.value(for: context.locale) { return provider }
        return context.deviceType == .pad ? hamsteriPadProvider : hamsteriPhoneProvider
    }
}
