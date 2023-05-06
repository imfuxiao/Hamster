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
  let rimeContext: RimeContext

  init(keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext
  }

  func calloutActions(for action: KeyboardKit.KeyboardAction) -> [KeyboardKit.KeyboardAction] {
    switch action {
    case .keyboardType(let type):
      if type == .numeric {
        return [
          .character(FunctionalInstructions.selectInputSchema.rawValue),
//          .character(FunctionalInstructions.selectColorSchema.rawValue),
        ]
      }
      return []
    default:
      return []
    }
  }
}
