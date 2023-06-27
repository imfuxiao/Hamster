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
  private let keyboardContext: KeyboardContext

  public init(keyboardContext: KeyboardContext) {
    self.keyboardContext = keyboardContext
  }

  // 主键盘
  private let padChineseAlphabetic = AlphabeticInputSet(rows: [
    .init(chars: "qwertyuiop"),
    .init(chars: "asdfghjkl"),
    .init(chars: "zxcvbnm,."),
  ])
  
  private let phoneChineseAlphabetic = AlphabeticInputSet(rows: [
    .init(chars: "qwertyuiop"),
    .init(chars: "asdfghjkl"),
    .init(chars: "zxcvbnm"),
  ])

  public var alphabeticInputSet: AlphabeticInputSet {
    if self.keyboardContext.deviceType == .pad {
      return padChineseAlphabetic
    } else {
      return phoneChineseAlphabetic
    }
  }
  
  // 数字键盘
  private let padChineseNumeric = NumericInputSet(rows: [
    .init(chars: "1234567890"),
    .init(chars: "@#¥/（）“”’"),
    .init(chars: "%-～…、；：，。"),
  ])
  
  private let phoneChineseNumeric = NumericInputSet(rows: [
    .init(chars: "1234567890"),
    .init(chars: "-/：；（）￥@“”"),
    .init(chars: "。，、？！.")
  ])
  
  public var numericInputSet: NumericInputSet {
    if self.keyboardContext.deviceType == .pad {
      return padChineseNumeric
    } else {
      return phoneChineseNumeric
    }
  }

  // 九宫格数字键盘
  public let numericNineGridInputSet: NumericInputSet = .chineseNineGrid()
  
  // 符号键盘
  private let padChineseSymbolic = SymbolicInputSet(rows: [
    .init(chars: "^_｜\\<>{},."),
    .init(chars: "&$€*【】「」•"),
    .init(chars: "。—+=·《》！？")
  ])
  
  private let phoneChineseSymbolic = SymbolicInputSet(rows: [
    .init(chars: "【】｛｝#%^*+="),
    .init(chars: "_—\\｜～《》$&·"),
    .init(chars: "…，。？！‘")
  ])
  
  public var symbolicInputSet: SymbolicInputSet {
    if self.keyboardContext.deviceType == .pad {
      return padChineseSymbolic
    } else {
      return phoneChineseSymbolic
    }
  }
}

public extension NumericInputSet {
  static func chineseNineGrid() -> NumericInputSet {
    .init(rows: [
      .init(chars: "123"),
      .init(chars: "456"),
      .init(chars: "789"),
      .init(chars: "0.")
    ])
  }
}
