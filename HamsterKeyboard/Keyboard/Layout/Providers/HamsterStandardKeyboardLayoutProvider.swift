import Foundation
import KeyboardKit
import SwiftUI

class HamsterStandardKeyboardLayoutProvider: StandardKeyboardLayoutProvider {
  let appSettings: HamsterAppSettings

  init(
    keyboardContext: KeyboardContext,
    inputSetProvider: InputSetProvider,
    localizedProviders: [LocalizedKeyboardLayoutProvider] = [],
    appSettings: HamsterAppSettings)
  {
    self.appSettings = appSettings
    
    super.init(keyboardContext: keyboardContext, inputSetProvider: inputSetProvider, localizedProviders: localizedProviders)
  }

  /**
   The layout provider that is used for iPad devices.
   */
  lazy var hamsteriPadProvider = HamsteriPadKeyboardLayoutProvider(
    inputSetProvider: inputSetProvider)

  /**
   The layout provider that is used for iPhone devices.
   */
  lazy var hamsteriPhoneProvider = HamsteriPhoneKeyboardLayoutProvider(
    inputSetProvider: inputSetProvider,
    appSettings: appSettings)

  override func keyboardLayoutProvider(for context: KeyboardContext) -> KeyboardLayoutProvider {
    if let provider = localizedProviders.value(for: context.locale) { return provider }
    return context.deviceType == .pad ? hamsteriPadProvider : hamsteriPhoneProvider
  }
}
