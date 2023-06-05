//
//  MostRecentEmojiProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-16.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This emoji provider can be used to return the most recently
 used emojis.
 
 该表情符号 provider 可用于返回最近使用的表情符号。
 
 This class implements `FrequentEmojiProvider` but is simple
 compared to a real "frequent" provider, which should keep a
 list of recent and still relevant emojis, remember taps etc.
 
 该类实现了 "FrequentEmojiProvider"，但与真正的 "frequent(常用)" provider 相比，
 该类非常简单，它应该保存最近且仍然相关的表情符号列表，并记住点击次数等等。
 */
public class MostRecentEmojiProvider: FrequentEmojiProvider {
  /**
   Create an instance of the provider.
   
   创建 provider 的实例。
     
   - Parameters:
     - maxCount: The max number of emojis to remember. 要记住的表情符号的最大数量。
     - defaults: The store used to persist emojis. 用于保存常用的表情符号
   */
  public init(
    maxCount: Int = 30,
    defaults: UserDefaults = .standard
  ) {
    self.maxCount = maxCount
    self.defaults = defaults
  }
    
  private let defaults: UserDefaults
  private let maxCount: Int
  private let key = "com.keyboardkit.MostRecentEmojiProvider.emojis"
    
  /**
   The persisted emoji characters mapped to `Emoji` values.
   
   将持久化的常用表情符号字符串映射为 `Emoji` 类型
   */
  public var emojis: [Emoji] {
    emojiChars.map { Emoji($0) }
  }
    
  /**
   The persisted emoji characters.
   
   持久化的表情符号字符串
   */
  public var emojiChars: [String] {
    defaults.stringArray(forKey: key) ?? []
  }
    
  /**
   Register that an emoji has been used. This will be used
   to prepare the emojis that will be returned by `emojis`.
   
   注册使用的表情符号。这些表情符号将由 `emojis`属性返回
   */
  public func registerEmoji(_ emoji: Emoji) {
    var emojis = self.emojis.filter { $0.char != emoji.char }
    emojis.insert(emoji, at: 0)
    let result = Array(emojis.prefix(maxCount))
    let chars = result.map { $0.char }
    defaults.set(chars, forKey: key)
  }
}
