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

// MARK: - Sentence 句子

public extension String {
  /// Whether or not this is a western sentence delimiter.
  ///
  /// 是否包含西文的句子分隔符。
  var isSentenceDelimiter: Bool {
    Self.sentenceDelimiters.contains(self)
  }

  /// Whether or not this is a western word delimiter.
  ///
  /// 是否否包含西文的单词分隔符。
  var isWordDelimiter: Bool {
    Self.wordDelimiters.contains(self)
  }

  /**
   Check whether or not the last character within a string
   is a sentence delimiter.

   检查字符串中的最后一个字符是否为西文的句子分隔符。
   */
  var hasSentenceDelimiterSuffix: Bool {
    String(last ?? Character("")).isSentenceDelimiter
  }

  /**
   Check whether or not the last sentence in the string is
   ended, with or without trailing whitespace.

   检测是否为西文的整句结束，或空字符串（忽略结尾处的空白字符）
   */
  var isLastSentenceEnded: Bool {
    let content = trimming(.whitespaces).replacingOccurrences(of: "\n", with: "")
    if content.isEmpty { return true }
    let lastCharacter = String(content.suffix(1))
    return lastCharacter.isSentenceDelimiter
  }

  /**
   Check whether or not the last sentence in the string is
   ended with trailing whitespace.

   检测是否为西文的整句结束，或整句已空格或换行符号结束。
   */
  var isLastSentenceEndedWithTrailingWhitespace: Bool {
    let trimmed = trimming(.whitespacesAndNewlines)
    if isEmpty || trimmed.isEmpty { return true }
    let lastTrimmed = String(trimmed.suffix(1))
    let isLastSpace = last?.isWhitespace == true
    let isLastNewline = last?.isNewline == true
    let isLastValid = isLastSpace || isLastNewline
    return lastTrimmed.isSentenceDelimiter && isLastValid
  }

  /**
   Get the content of the last sentence, if any. Note that
   it will not contain the sentence delimiter.

   获取字符串中最后一句的内容（如果有）。
   注意: 内容不包含西文的句子分隔符。
   */
  var lastSentence: String? {
    guard isLastSentenceEnded else { return nil }
    let components = split(by: Self.sentenceDelimiters).filter { !$0.isEmpty }
    let trimmed = components.last?.trimming(.whitespaces)
    let ignoreLast = trimmed?.count == 0
    return ignoreLast ? nil : components.last
  }
}

public extension String {
  /// 字符串的最后一个字符
  var lastCharacter: String? {
    guard let last = last else { return nil }
    return String(last)
  }

  /// 整个字符串中最后一个西文语句
  var lastSentenceSegment: String {
    lastSegment(isSegmentDelimiter: { $0.isSentenceDelimiter })
  }

  /// 整个字符串中最后一个西文单词
  var lastWordSegment: String {
    lastSegment(isSegmentDelimiter: { $0.isWordDelimiter })
  }

  /// 按给定的 `isSegmentDelimiter` 给定分隔符号的闭包拆分，并返回最后一个部分
  func lastSegment(isSegmentDelimiter: (String) -> Bool) -> String {
    var result = last { $0.isWhitespace }.map { String($0) } ?? ""
    var text = trimming(.whitespaces)
    var foundNonDelimiter = false
    while let char = text.popLast() {
      let char = String(char)
      let isDelimiter = isSegmentDelimiter(char)
      if isDelimiter && foundNonDelimiter { break }
      foundNonDelimiter = !isDelimiter
      result.append(char)
    }
    return String(result.reversed())
  }
}
