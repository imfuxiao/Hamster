//
//  InputSet.swift
//  HamsterKeyboard
//
//  Created by morse on 4/3/2023.
//

import Foundation
import KeyboardKit

struct NumberNineGridInputSet: InputSet {
  var rows: KeyboardKit.InputSetRows

  init(rows: KeyboardKit.InputSetRows) {
    self.rows = rows
  }
}

extension NumberNineGridInputSet {
  static let numberNineGrid: NumberNineGridInputSet = .init(rows: [
    .init(chars: "+123"),
    .init(chars: "-456*"),
    .init(chars: "789/"),
    .init(chars: ",0."),
  ])
}

public struct ChineseSymbolicInputSet: InputSet {
  public init(rows: InputSetRows) {
    self.rows = rows
  }

  public var rows: InputSetRows
}

public extension ChineseSymbolicInputSet {
  /**
   A standard symbolic input set, used by e.g. the English
   symbolic input sets.
   */
  static func standard() -> ChineseSymbolicInputSet {
    ChineseSymbolicInputSet(rows: [
      .init(phone: "【】｛｝#%^*+=", pad: "1234567890"),
      .init(
        phone: "_－＼｜～《》￥&•",
        pad: "_^[]{}"),
      .init(phone: "…，？！’", pad: "§|~…\\<>!?"),
    ])
  }
}
