//
//  FrequentEmojiProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-16.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by classes that can return
 a list of frequently used emojis.
 
 该协议可以通过可以返回常用表情符号列表的类来实现。
 
 When using this protocol, you should trigger `registerEmoji`
 whenever a user selects an emoji, then use the registration
 to populate a frequent list that is returned by `emojis`.
 
 使用此协议时，每当用户选择一个表情符号时, 都会触发 `registerEmoji`，
 然后该协议的实现者会保存这个 emoji, 最终调用 EmojiProvider 协议的 `emojis` 返回的这些常用表情符号的 list。
 */
public protocol FrequentEmojiProvider: EmojiProvider {
  /**
   Register that an emoji has been used. This will be used
   to prepare the emojis that will be returned by `emojis`.
     
   注册已使用的 emoji。注册的 emoji 将由 `emojis` 属性返回。
   */
  func registerEmoji(_ emoji: Emoji)
}
