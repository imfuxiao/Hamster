//
//  String+.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-03.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension String {
  /**
   Split the string into a list of individual characters.

   将字符串分割成单个字符的List。
   */
  var chars: [String] {
    map(String.init)
  }

  func split(by separators: [String]) -> [String] {
    let separators = CharacterSet(charactersIn: separators.joined())
    return components(separatedBy: separators)
  }

  func trimming(_ set: CharacterSet) -> String {
    trimmingCharacters(in: set)
  }

  /**
   Whether or not the string is capitalized.

   字符串是否首字母大写。
   */
  var isCapitalized: Bool {
    self == capitalized
  }

  /**
   Whether or not the string is lowercased.

   字符串是否小写。

   This only returns true if the string is lowercased, but
   doesn't have an uppercased variant.

   只有当字符串小写但没有大写变体时，才返回 true。
   */
  var isLowercased: Bool {
    self == lowercased() && self != uppercased()
  }

  /**
   Whether or not the string is uppercased.

   字符串是否大写。

   This only returns true if the string is uppercased, but
   doesn't have a lowercased variant.

   只有当字符串是大写字母，但没有小写字母变体时，才返回 true。
   */
  var isUppercased: Bool {
    self == uppercased() && self != lowercased()
  }
}

// MARK: - Symbols 定义按键操作对应符号

public extension String {
  /// A carriage return character.
  ///
  /// 回车符
  static let carriageReturn = "\r"

  /// A new line character.
  ///
  /// 换行
  static let newline = "\n"

  /// A space character.
  ///
  /// 空格字符
  static let space = " "

  /// A tab character.
  ///
  /// 制表符。
  static let tab = "\t"

  /// A zero width space character used in some RTL languages.
  ///
  /// 某些 RTL(从右到左) 的语言中使用的零宽度空格字符。
  static let zeroWidthSpace = "\u{200B}"

  /// A list of mutable western sentence delimiters.
  ///
  /// 可变列表，表示西方语言的整句分隔符。
  static var sentenceDelimiters = ["!", ".", "?"]

  /// A list of mutable western word delimiters.
  ///
  /// 可变列表，表示西方单词分隔符。
  static var wordDelimiters = "!.?,;:()[]{}<>".chars + [" ", .newline]
}

// MARK: - 字符串引号/备用引号处理

public extension String {
  /**
   Check whether or not the last trailing quotation in the
   string is an alternate quotation begin delimiter.

   检查字符串中最后一个结尾的引号是否为备用引号(alternate quotation)分隔符。

   备用引号在不同的语言环境中不同，比如：alternateQuotationBeginDelimiter 方法中
   `‘` for "en_US", and `『` for "zh-Hant-HK".
   */
  func hasUnclosedAlternateQuotation(for locale: Locale) -> Bool {
    guard let begin = locale.alternateQuotationBeginDelimiter else { return false }
    guard let end = locale.alternateQuotationEndDelimiter else { return false }
    return hasUnclosedQuotation(beginDelimiter: begin, endDelimiter: end)
  }

  /**
   Check whether or not the last trailing quotation in the
   string is a quotation begin delimiter.

   检查字符串中最后一个尾部引号是否是引号开头分隔符。

   引号在不同的语言环境中不同，比如：quotation 在中文繁体和英文中
   returns `“` for "en_US", and `「` for "zh-Hant-HK".
   */
  func hasUnclosedQuotation(for locale: Locale) -> Bool {
    guard let begin = locale.quotationBeginDelimiter else { return false }
    guard let end = locale.quotationEndDelimiter else { return false }
    return hasUnclosedQuotation(beginDelimiter: begin, endDelimiter: end)
  }

  /**
   Whether or not the last trailing quotation character is
   a begin delimiter for the provided locale.

   是否有未关闭的引号，对于所提供的本地语言，最后一个尾部引号字符是否是开头分隔符。
   */
  func hasUnclosedQuotation(
    beginDelimiter begin: String,
    endDelimiter end: String
  ) -> Bool {
    let string = String(reversed())
    guard let beginIndex = (string.firstIndex { String($0) == begin }) else { return false }
    guard let endIndex = (string.firstIndex { String($0) == end }) else { return true }
    return beginIndex < endIndex
  }

  /**
   Check if a certain text that is about to be appended to
   the string should be replaced with something else.

   检查即将添加到字符串中的某个文本是否应替换为其他内容。
   */
  func preferredQuotationReplacement(
    whenAppending text: String,
    for locale: Locale
  ) -> String? {
    if let replacement = preferredQuotationReplacement(for: text, locale: locale) { return replacement }
    if let replacement = preferredAlternateQuotationReplacement(for: text, locale: locale) { return replacement }
    return nil
  }

  /**
   Wrap the string in quotation delimiters for a `locale`.

   将字符串用本地语言（local）下的引号包起来
   注意：不同语言环境下的引号不同
   */
  func quoted(for locale: Locale) -> String {
    guard let begin = locale.quotationBeginDelimiter else { return self }
    guard let end = locale.quotationEndDelimiter else { return self }
    return "\(begin)\(self)\(end)"
  }

  /**
   Wrap the string in alternate quotation delimiters for a
   `locale`.

   将字符串用本地语言（local）下的备用引号包起来
   注意：不同语言环境下的备用引号不同
   */
  func alternateQuoted(for locale: Locale) -> String {
    guard let begin = locale.alternateQuotationBeginDelimiter else { return self }
    guard let end = locale.alternateQuotationEndDelimiter else { return self }
    return "\(begin)\(self)\(end)"
  }
}

private extension String {
  /// 首选引号替换
  func preferredQuotationReplacement(for text: String, locale: Locale) -> String? {
    guard text == locale.quotationEndDelimiter || (text == "”" && text != locale.alternateQuotationEndDelimiter) else { return nil }
    let isOpen = hasUnclosedQuotation(for: locale)
    let result = isOpen ? locale.quotationEndDelimiter : locale.quotationBeginDelimiter
    return result == text ? nil : result
  }

  /// 备选引号替换
  func preferredAlternateQuotationReplacement(for text: String, locale: Locale) -> String? {
    guard locale.prefersAlternateQuotationReplacement else { return nil }
    guard text == locale.alternateQuotationEndDelimiter || text == "‘" else { return nil }
    let isOpen = hasUnclosedAlternateQuotation(for: locale)
    let result = isOpen ? locale.alternateQuotationEndDelimiter : locale.alternateQuotationBeginDelimiter
    return result == text ? nil : result
  }
}
