//
//  KeyboardAutocapitalizationType.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-03-26.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This enum defines all supported auto-capitalization types.

 该枚举定义了所有支持的自动大写类型。
 */
public enum KeyboardAutocapitalizationType: String, CaseIterable {
  /// All characters should be auto-capitalized.
  ///
  /// 所有字符均应自动大写。
  case allCharacters

  /// All new sentences should be auto-capitalized.
  ///
  /// 所有新句子都应自动大写。
  case sentences

  /// All new words should be auto-capitalized.
  ///
  /// 所有新单词都应自动大写。
  case words

  /// Auto-capitalization should not be applied.
  ///
  /// 不应使用自动大写。
  case none
}

public extension UITextAutocapitalizationType {
  /**
   Get the KeyboardKit-specific auto-capitalization type.

   获取特定于 KeyboardKit 的自动大写类型。
   */
  var keyboardType: KeyboardAutocapitalizationType {
    switch self {
    case .none: return .none
    case .words: return .words
    case .sentences: return .sentences
    case .allCharacters: return .allCharacters
    @unknown default: return .none
    }
  }
}
