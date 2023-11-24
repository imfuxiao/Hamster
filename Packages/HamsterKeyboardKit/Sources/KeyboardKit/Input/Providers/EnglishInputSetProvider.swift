//
//  EnglishInputSetProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This input set provider returns standard English input sets.

 该输入集提供程序返回标准英文输入集。

 Since currencies can vary between English keyboards, we can
 override the currency symbols that are shown in the numeric
 and symbolic keyboards.

 由于不同的英文键盘上显示的货币可能不同，
 因此我们可以覆盖数字键盘和符号键盘上显示的货币符号。
 */
open class EnglishInputSetProvider: InputSetProvider {
  /**
   The input set to use for alphabetic keyboards.

   用于字母键盘的输入集。
   */
  public var alphabeticInputSet: AlphabeticInputSet

  /**
   The input set to use for numeric keyboards.

   数字键盘使用的输入集。
   */
  public var numericInputSet: NumericInputSet

  /**
   The input set to use for symbolic keyboards.

   用于符号键盘的输入集。
   */
  public var symbolicInputSet: SymbolicInputSet

  /**
   Create an English input set provider.

   This input set supports QWERTY, QWERTZ and AZERTY, with
   QWERTY being the default.

   - Parameters:
     - alphabetic: The alphabetic input set to use, by default ``AlphabeticInputSet/english``.
     - numericCurrency: The currency to use for the numeric input set, by default `$`.
     - symbolicCurrency: The currency to use for the symbolic input set, by default `£`.
   */
  public init(
    alphabetic: AlphabeticInputSet = .english,
    numericCurrency: String = "$",
    symbolicCurrency: String = "£"
  ) {
    self.alphabeticInputSet = alphabetic
    self.numericInputSet = .english(currency: numericCurrency)
    self.symbolicInputSet = .english(currency: symbolicCurrency)
  }
}

public extension AlphabeticInputSet {
  /**
   A standard, English input set.

   一套标准的英文输入集。
   */
  static let english = AlphabeticInputSet(rows: [
    .init(chars: "qwertyuiop"),
    .init(chars: "asdfghjkl"),
    .init(phone: "zxcvbnm", pad: "zxcvbnm,.")
  ])
}

public extension NumericInputSet {
  /**
   A standard, numeric input set, used by e.g. the English
   numeric input sets.

   标准的数字输入集，如英文数字输入集。
   */
  static func standard(currency: String) -> NumericInputSet {
    NumericInputSet(rows: [
      .init(chars: "1234567890"),
      .init(phone: "-/:;()\(currency)&@\"", pad: "@#\(currency)&*()'\""),
      .init(phone: ".,?!'", pad: "%-+=/;:!?")
    ])
  }

  /**
   A standard, English number input set.

   一套标准的英文数字输入集。
   */
  static func english(currency: String) -> NumericInputSet {
    .standard(currency: currency)
  }
}

public extension SymbolicInputSet {
  /**
   A standard symbolic input set, used by e.g. the English
   symbolic input sets.

   标准符号输入集，例如英语符号输入集。
   */
  static func standard(currencies: [String]) -> SymbolicInputSet {
    SymbolicInputSet(rows: [
      .init(phone: "[]{}#%^*+=", pad: "1234567890"),
      .init(
        phone: "_\\|~<>\(currencies.joined())•",
        pad: "\(currencies.joined())_^[]{}"
      ),
      .init(phone: ".,?!’", pad: "§|~…\\<>!?")
    ])
  }

  /**
   A standard, English symbols input set.

   一套标准的英文符号输入法。
   */
  static func english(currency: String) -> SymbolicInputSet {
    .standard(currencies: "€\(currency)¥".chars)
  }
}
