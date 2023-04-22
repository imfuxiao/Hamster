import Foundation
import KeyboardKit
import SwiftUI

class HamsterStandardKeyboardLayoutProvider: StandardKeyboardLayoutProvider {
  let appSettings: HamsterAppSettings
  let rimeEngine: RimeEngine
  let hamsterInputSetProvider: HamsterInputSetProvider

  init(
    keyboardContext: KeyboardContext,
    inputSetProvider: HamsterInputSetProvider,
    localizedProviders: [LocalizedKeyboardLayoutProvider] = [],
    appSettings: HamsterAppSettings,
    rimeEngine: RimeEngine
  ) {
    self.appSettings = appSettings
    self.rimeEngine = rimeEngine
    self.hamsterInputSetProvider = inputSetProvider
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
    inputSetProvider: hamsterInputSetProvider,
    appSettings: appSettings,
    rimeEngine: rimeEngine
  )

  override func keyboardLayoutProvider(for context: KeyboardContext) -> KeyboardLayoutProvider {
    if let provider = localizedProviders.value(for: context.locale) { return provider }
    return context.deviceType == .pad ? hamsteriPadProvider : hamsteriPhoneProvider
  }

  // TODO: 也可以在这里改变键盘布局
  override open func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    let layout = keyboardLayoutProvider(for: context)
      .keyboardLayout(for: context)

    layout.idealItemInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    return layout
  }
}
