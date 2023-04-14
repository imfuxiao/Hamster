//
//  HamsterCalloutActionProvider.swift
//  HamsterKeyboard
//
//  Created by morse on 14/4/2023.
//

import Foundation
import KeyboardKit

class HamsterCalloutActionProvider: CalloutActionProvider {
  let keyboardContext: KeyboardContext
  let rimeEngine: RimeEngine

  init(keyboardContext: KeyboardContext, rimeEngine: RimeEngine) {
    self.keyboardContext = keyboardContext
    self.rimeEngine = rimeEngine
  }

  func calloutActions(for action: KeyboardKit.KeyboardAction) -> [KeyboardKit.KeyboardAction] {
    switch action {
    default:
      return []
    }
  }
}
