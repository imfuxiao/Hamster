//
//  EmojiAnalyzer.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2022-01-07.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any type that should be
 able to analyze emoji information for stings and characters.

 该协议可以由任何能够分析表情符号信息以查找字符和字符的类型来实现。

 Implementing the protocol will extend the implementing type
 with functions that use `String` and `Character` extensions
 with the same name. You can use the extensions directly and
 ignore the protocol, but the protocol exposes functionality
 to the library documentation.

 实现协议将使用使用同名的 `String` 和 `Character` extension 中的函数来扩展实现类型。
 您可以直接使用扩展并忽略协议，但协议会向文档库公开函数说明。
 */
public protocol EmojiAnalyzer {}

public extension EmojiAnalyzer {
  /**
   Whether or not the string contains an emoji.

   字符串是否包含表情符号。
   */
  func containsEmoji(_ string: String) -> Bool {
    string.containsEmoji
  }

  /**
   Whether or not the string only contains emojis.

   字符串是否只包含表情符号。
   */
  func containsOnlyEmojis(_ string: String) -> Bool {
    string.containsOnlyEmojis
  }

  /**
   Extract all emoji characters from the string.

   从字符串中提取所有表情符号。
   */
  func emojis(in string: String) -> [Character] {
    string.emojis
  }

  /**
   Extract all emoji scalars from the string.

   从字符串中提取所有表情符号的Unicode标量值。
   */
  func emojiScalars(in string: String) -> [UnicodeScalar] {
    string.emojiScalars
  }

  /**
   Extract all emojis in the string.

   提取字符串中的所有表情符号的子字符串。
   */
  func emojiString(in string: String) -> String {
    string.emojiString
  }

  /**
   Whether or not a character is a an emoji.

   字符是否是表情符号。
   */
  func isEmoji(_ char: Character) -> Bool {
    char.isEmoji
  }

  /**
   Whether or not the character consists of unicodeScalars
   that will be merged into an emoji.

   字符是否由表情符号的 Unicode 标量组成，这些字符将被合并为一个表情符号。
   */
  func isCombinedEmoji(_ char: Character) -> Bool {
    char.isCombinedEmoji
  }

  /**
   Whether or not the character is a "simple emoji", which
   is a single scalar that is presented as an emoji.

   字符是否为 "simple emoji"，即作为一个表情符号呈现的单一标量。
   */
  func isSimpleEmoji(_ char: Character) -> Bool {
    char.isSimpleEmoji
  }

  /**
   Whether or not the string is a single emoji.

   字符串是否为单个表情符号。
   */
  func isSingleEmoji(_ string: String) -> Bool {
    string.isSingleEmoji
  }
}

// MARK: - Character

public extension Character {
  /**
   Whether or not the character is a an emoji.

   字符是否为表情符号。
   */
  var isEmoji: Bool {
    let iOS_16_4 = "🫨🫸🫷🪿🫎🪼🫏🪽🪻🫛🫚🪇🪈🪮🪭🩷🩵🩶🪯🛜"
    return isCombinedEmoji || isSimpleEmoji || iOS_16_4.contains(self)
  }

  /**
   Whether or not the character consists of unicodeScalars
   that will be merged into an emoji.

   字符是否由 Unicode 标量组成，这些字符将被合并为一个表情符号。
   */
  var isCombinedEmoji: Bool {
    let scalars = unicodeScalars
    guard scalars.count > 1 else { return false }
    return scalars.first?.properties.isEmoji ?? false
  }

  /**
   Whether or not the character is a "simple emoji", which
   is one scalar and presented to the user as an Emoji.

   字符是否为 "simple emoji"，即一个标量并作为表情符号呈现给用户。
   */
  var isSimpleEmoji: Bool {
    guard let scalar = unicodeScalars.first else { return false }
    return scalar.properties.isEmoji && scalar.value > 0x238C
  }
}

// MARK: - String

public extension String {
  /**
   Whether or not the string contains an emoji.

   字符串是否包含表情符号。
   */
  var containsEmoji: Bool {
    contains { $0.isEmoji }
  }

  /**
   Whether or not the string only contains emojis.

   字符串是否只包含表情符号。
   */
  var containsOnlyEmojis: Bool {
    !isEmpty && !contains { !$0.isEmoji }
  }

  /**
   Extract all emoji characters from the string.

   从字符串中提取所有表情符号。
   */
  var emojis: [Character] {
    filter { $0.isEmoji }
  }

  /**
   Extract all emoji scalars from the string.

   从字符串中提取所有表情符号的 Unicode 标量值。
   */
  var emojiScalars: [UnicodeScalar] {
    filter { $0.isEmoji }.flatMap { $0.unicodeScalars }
  }

  /**
   Extract all emojis in the string.

   提取字符串中的所有表情符号。
   */
  var emojiString: String {
    emojis.map { String($0) }.reduce("", +)
  }

  /**
   Whether or not the string is a single emoji.

   字符串是否为单个表情符号。
   */
  var isSingleEmoji: Bool {
    count == 1 && containsEmoji
  }
}
