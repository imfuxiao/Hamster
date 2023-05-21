//
//  HamsterInputProvider.swift
//  HamsterKeyboard
//
//  Created by morse on 3/4/2023.
//

import Foundation
import KeyboardKit

class HamsterInputSetProvider: InputSetProvider {
  public init(
    keyboardContext: KeyboardContext,
    appSettings: HamsterAppSettings,
    rimeContext: RimeContext
  ) {
    self.keyboardContext = keyboardContext
    self.appSettings = appSettings
    self.rimeContext = rimeContext
  }

  public let keyboardContext: KeyboardContext
  var appSettings: HamsterAppSettings
  var rimeContext: RimeContext

  let chineseProvider = ChineseInputSetProvider()
  let englishProvider = EnglishInputSetProvider()

  /**
   为某一键盘环境而使用的提供者。
   */
  func provider() -> InputSetProvider {
    rimeContext.asciiMode ? englishProvider : chineseProvider
  }

  var alphabeticInputSet: AlphabeticInputSet {
    provider().alphabeticInputSet
  }

  var numericInputSet: NumericInputSet {
    appSettings.enableNumberNineGrid ? chineseProvider.numericNineGridInputSet : provider().numericInputSet
  }

  var symbolicInputSet: SymbolicInputSet {
    provider().symbolicInputSet
  }
}
