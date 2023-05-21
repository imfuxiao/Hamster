//
//  Appearance+Preview.swift
//  Hamster
//
//  Created by morse on 2023/5/25.
//

import KeyboardKit
import SwiftUI

public extension HamsterKeyboardAppearance {
  static var preview: HamsterKeyboardAppearance { PreviewHamstterKeyboardAppearance() }
}

class PreviewHamstterKeyboardAppearance: HamsterKeyboardAppearance {
  init() {
    super.init(keyboardContext: KeyboardContext.preview, rimeContext: RimeContext(), appSettings: HamsterAppSettings())
  }
}
