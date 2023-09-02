//
//  ChineseInputSetProvider.swift

import Foundation

/**
 中文键盘输入集合
 */
open class ChineseInputSetProvider: InputSetProvider {
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

  public init(
    alphabetic: AlphabeticInputSet = .chinese
  ) {
    self.alphabeticInputSet = alphabetic
    self.numericInputSet = .chinese
    self.symbolicInputSet = .chinese
  }
}

public extension AlphabeticInputSet {
  /**
   中文标准26键
   */
  static let chinese = AlphabeticInputSet(rows: [
    .init(chars: "qwertyuiop"),
    .init(chars: "asdfghjkl"),
    .init(phone: "zxcvbnm", pad: "zxcvbnm，。")
  ])
}

public extension NumericInputSet {
  /// 中文键盘数字
  static let chinese = NumericInputSet(rows: [
    .init(chars: "1234567890"),
    .init(phone: "-/：；（）$@“”", pad: "@#$/（）“”‘"),
    .init(phone: "。，、？！.", pad: "%-~…、；：，。")
  ])
}

public extension SymbolicInputSet {
  /// 中文键盘符号
  static let chinese = SymbolicInputSet(rows: [
    .init(phone: "【】｛｝#%^*+=", pad: "^_｜\\<>{},."),
    .init(phone: "_—\\|~《》￥&·", pad: "&¥€*【】「」•"),
    .init(phone: "…。，？！‘", pad: "_—+=·《》！？")
  ])
}
