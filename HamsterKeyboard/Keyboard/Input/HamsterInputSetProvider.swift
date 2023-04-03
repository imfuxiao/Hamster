//
//  HamsterInputProvider.swift
//  HamsterKeyboard
//
//  Created by morse on 3/4/2023.
//

import Foundation
import KeyboardKit

class HamsterInputSetProvider: StandardInputSetProvider {
  override init(
    keyboardContext: KeyboardContext,
    localizedProviders: [LocalizedInputSetProvider] = [EnglishInputSetProvider()]
  ) {
    super.init(keyboardContext: keyboardContext, localizedProviders: localizedProviders)
  }

  var numberNineGridInputSet: GridInputSet {
    .numberGrid
  }
}
