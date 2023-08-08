//
//  EmojiProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-16.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to get a list of emojis.

 该协议可以由任何可用于获取表情符号 list 的类来实现。
 */
public protocol EmojiProvider {
  /**
   The emojis being returned by the provider.

   返回的表情符号。
   */
  var emojis: [Emoji] { get }
}
