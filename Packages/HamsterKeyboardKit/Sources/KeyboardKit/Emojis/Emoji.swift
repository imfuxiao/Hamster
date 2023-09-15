//
//  Emoji.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-17.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This struct is just a wrapper around a single character. It
 can be used to get a little bit of type safety, and to work
 more structured with emojis.

 该 struct 只是对单个字符的封装。它可以用来获得一点类型安全，并使表情符号的工作更有条理。
 */
public struct Emoji: Hashable, Codable, Identifiable {
  /**
   Create an emoji instance, using a certain emoji `char`.

   使用某个表情符号 `char` 创建表情符号实例。
   */
  public init(_ char: String) {
    self.char = char
  }

  /**
   The character that can be used to display the emoji.

   可用于显示表情符号的字符。
   */
  public let char: String
}

public extension Emoji {
  /**
   The emoji's unique identifier.

   表情符号的唯一标识符。
   */
  var id: String { char }
}

public extension Emoji {
  /**
   Get all emojis from all categories.

   获取所有类别的所有表情符号。
   */
  static var all: [Emoji] {
    EmojiCategory.all.flatMap { $0.emojis }
  }
}
