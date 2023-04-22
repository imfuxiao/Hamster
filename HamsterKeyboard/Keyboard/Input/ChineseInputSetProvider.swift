//
//  ChineseInputSetProvider.swift
//  HamsterKeyboard
//
//  Created by morse on 22/4/2023.
//

import Foundation
import KeyboardKit

/**
 中文符号集
 */
public class ChineseInputSetProvider: InputSetProvider, LocalizedService {
  public var localeKey: String = "cn"

  public init() {}

  public var alphabeticInputSet: AlphabeticInputSet = .chinese
  public let numericInputSet: NumericInputSet = .chinese()
  public let numericNineGridInputSet: NumericInputSet = .chineseNineGrid()
  public let symbolicInputSet: SymbolicInputSet = .chinese()
}

public extension AlphabeticInputSet {
  static let chinese = AlphabeticInputSet.qwerty
}

public extension NumericInputSet {
  static func chinese() -> NumericInputSet {
    NumericInputSet(rows: [
      .init(chars: "1234567890"),
      .init(phone: "-/：；（）￥@“”", pad: "-/：；（）￥@“”"),
      .init(phone: "。，、？！.", pad: "。，、？！.")
    ])
  }

  static func chineseNineGrid() -> NumericInputSet {
    .init(rows: [
      .init(chars: "+123"),
      .init(chars: "-456*"),
      .init(chars: "789/"),
      .init(chars: ".0=")
    ])
  }
}

public extension SymbolicInputSet {
  static func chinese() -> SymbolicInputSet {
    SymbolicInputSet(rows: [
      .init(phone: "【】｛｝#%^*+=", pad: "【】｛｝#%^*+="),
      .init(
        phone: "_—\\｜～《》$&·",
        pad: "_—\\｜～《》$&·"
      ),
      .init(phone: "…，。？！‘", pad: "…，。？！‘")
    ])
  }
}
