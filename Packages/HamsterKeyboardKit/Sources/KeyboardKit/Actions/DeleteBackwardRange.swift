//
//  DeleteBackwardRange.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-05-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum can be used to vary how the backspace action will
 behave when pressing and holding the backspace key.

 该枚举可用于改变按住退格键时退格操作的行为方式。
 */
public enum DeleteBackwardRange {
  /// Delete a single char at a time.
  ///
  /// 每次删除一个字符。
  case character

  /// Delete an entire word at a time.
  ///
  /// 每次删除整个单词。
  case word

  /// Delete an entire sentence at a time.
  ///
  /// 每次删除整个句子。
  case sentence
}
