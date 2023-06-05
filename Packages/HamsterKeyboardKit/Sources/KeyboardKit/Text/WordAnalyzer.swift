//
//  WordAnalyzer.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-28.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any type that should be
 able to analyze word information for strings.

 该协议可以由任何能够分析字符串中单词信息的类来实现。

 Implementing the protocol will extend the implementing type
 with functions that use public `String` extensions with the
 same names. While you can use the protocol, the main reason
 for having it is to expose these extensions to DocC.

 实现该协议将扩展实现类的函数，这些函数使用扩展 `String` 中相同的函数名。
 虽然你可以使用该协议，但拥有它的主要原因是为了向 DocC 公开这些扩展。
 */
public protocol WordAnalyzer {}

public extension WordAnalyzer {
  /**
   Check whether or not the last character in the provided
   string is a word delimiter.

   检查所提供字符串中的最后一个字符是否为西文单词分隔符。
   */
  func hasWordDelimiterSuffix(in string: String) -> Bool {
    string.hasWordDelimiterSuffix
  }

  /// Get the word or fragment at the start of the string.
  ///
  /// 获取字符串开头的单词或片段。
  func wordFragmentAtStart(in string: String) -> String {
    string.wordFragmentAtStart
  }

  /// Get the word or fragment at the end of the string.
  ///
  /// 获取字符串末尾的单词或片段。
  func wordFragmentAtEnd(in string: String) -> String {
    string.wordFragmentAtEnd
  }

  /// Get the word at a certain index in the string.
  ///
  /// 获取给定字符串，给个索引处的西文单词。
  func word(at index: Int, in string: String) -> String? {
    string.word(at: index)
  }

  /// Get the word fragment before a certain string index.
  ///
  /// 获取给定字符串，给定索引之前的单词片段。
  func wordFragment(before index: Int, in string: String) -> String {
    string.wordFragment(before: index)
  }

  /// Get the word fragment after a certain string index.
  ///
  /// 获取给定字符串，给定索引之后的单词片段。
  func wordFragment(after index: Int, in string: String) -> String {
    string.wordFragment(after: index)
  }
}

// MARK: - String

public extension String {
  /**
   Check whether or not the last character within a string
   is a word delimiter.

   检查字符串中的最后一个字符是否为西文单词分隔符。
   */
  var hasWordDelimiterSuffix: Bool {
    String(last ?? Character("")).isWordDelimiter
  }

  /// Get the word or fragment at the start of the string.
  ///
  /// 获取字符串开头的单词或片段。
  var wordFragmentAtStart: String {
    var reversed = String(self.reversed())
    var result = ""
    while let char = reversed.popLast() {
      guard shouldIncludeCharacterInCurrentWord(char) else { return result }
      result.append(char)
    }
    return result
  }

  /// Get the word or fragment at the end of the string.
  ///
  /// 获取字符串结尾的单词或片段。
  var wordFragmentAtEnd: String {
    var string = self
    var result = ""
    while let char = string.popLast() {
      guard shouldIncludeCharacterInCurrentWord(char) else { return result }
      result.insert(char, at: result.startIndex)
    }
    return result
  }

  /// Get the word at a certain index in the string.
  ///
  /// 获取字符串中给定索引处的单词。
  func word(at index: Int) -> String? {
    let prefix = wordFragment(before: index)
    let suffix = wordFragment(after: index)
    let result = prefix + suffix
    return result.isEmpty ? nil : result
  }

  /// Get the word fragment before a certain string index.
  ///
  /// 获取特定字符串索引之前的单词片段。
  func wordFragment(before index: Int) -> String {
    let splitIndex = self.index(startIndex, offsetBy: index)
    let prefix = String(prefix(upTo: splitIndex))
    return prefix.wordFragmentAtEnd
  }

  /// Get the word fragment after a certain string index.
  ///
  /// 获取给定字符串索引之后的单词片段。
  func wordFragment(after index: Int) -> String {
    let splitIndex = self.index(startIndex, offsetBy: index)
    let suffix = String(suffix(from: splitIndex))
    return suffix.wordFragmentAtStart
  }
}

private extension String {
  /// 判断在给定 Character 类型的 `character` 中，是否包含单词分隔符号
  func shouldIncludeCharacterInCurrentWord(_ character: Character) -> Bool {
    !"\(character)".isWordDelimiter
  }
}
