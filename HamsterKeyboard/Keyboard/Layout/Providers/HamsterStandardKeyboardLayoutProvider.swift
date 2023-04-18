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

  override open func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    let layout = keyboardLayoutProvider(for: context)
      .keyboardLayout(for: context)

    // TODO: 也可以在这里改变键盘布局
    if keyboardContext.isGridViewKeyboardType {
//      var rows = layout.itemRows
//      var row = layout.itemRows[0]
//      let next = row[0]
//      let size = KeyboardLayoutItemSize(width: .available, height: next.size.height)
//      let tab = KeyboardLayoutItem(action: .tab, size: size, insets: next.insets)
//      row.insert(tab, at: 0)
//      rows[0] = row
//      layout.itemRows = rows
    }
    return layout
  }
}
