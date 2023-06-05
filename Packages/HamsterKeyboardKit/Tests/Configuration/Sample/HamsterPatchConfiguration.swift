//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation

@testable import HamsterKeyboardKit

public extension HamsterPatchConfiguration {
  static let preview = HamsterPatchConfiguration(
    patch: HamsterConfiguration(
      general: GeneralConfiguration(
        enableAppleCloud: false
      ),
      toolbar: KeyboardToolbarConfiguration(
        enableToolbar: false
      ),
      keyboard: KeyboardConfiguration(
        displayButtonBubbles: false
      )
    )
  )

  static let preview2 = HamsterPatchConfiguration(patch: HamsterConfiguration.preview)
}
