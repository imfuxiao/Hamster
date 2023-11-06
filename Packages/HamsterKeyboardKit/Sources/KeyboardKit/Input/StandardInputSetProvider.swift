//
//  StandardInputSetProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This provider is initialized with a collection of localized
 providers, and will use the one with the same locale as the
 provided ``KeyboardContext``.

 该 provider 通过本地化提供程序集合进行初始化，并将使用与所提供的 ``KeyboardContext`` 具有相同本地化设置的 provider。
 */
open class StandardInputSetProvider: InputSetProviderProxy {
  /**
   The keyboard context to use.

   要使用的键盘上下文。
   */
  public let keyboardContext: KeyboardContext

  public lazy var englishProvider = EnglishInputSetProvider()
  public lazy var chineseProvider = ChineseInputSetProvider()

  /**
   Create a standard provider.

    - Parameters:
      - keyboardContext: The keyboard context to use.
      - provider: ``InputSetProvider`` instances, by default only `English`.
   */
  public init(
    keyboardContext: KeyboardContext
  ) {
    self.keyboardContext = keyboardContext
  }

  /**
   The provider to use for a certain keyboard context.

   用于特定键盘上下文的 provider。
   */
  open func provider(for context: KeyboardContext) -> InputSetProvider {
    context.keyboardType.isChinese ? chineseProvider : englishProvider
  }

  /**
   The input set to use for alphabetic keyboards.

   用于字母键盘的输入集。
   */
  open var alphabeticInputSet: AlphabeticInputSet {
    provider(for: keyboardContext).alphabeticInputSet
  }

  /**
   The input set to use for numeric keyboards.

   数字键盘使用的输入集。
   */
  open var numericInputSet: NumericInputSet {
    provider(for: keyboardContext).numericInputSet
  }

  /**
   The input set to use for symbolic keyboards.

   用于符号键盘的输入集。
   */
  open var symbolicInputSet: SymbolicInputSet {
    provider(for: keyboardContext).symbolicInputSet
  }
}
