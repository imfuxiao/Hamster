//
//  KeyboardContext+KeyboardType.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-28.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension KeyboardContext {
  /**
   The preferred keyboard type for the context is based on
   the current keyboard type and the text document proxy's
   autocapitalization type.

   上下文的首选键盘类型基于当前键盘类型和 ``textDocumentProxy`` 的自动大写类型。
   */
  var preferredKeyboardType: KeyboardType {
    if keyboardType.isAlphabetic(.capsLocked) { return keyboardType }

    // 中文输入不考虑切换
    if keyboardType.isChinese { return keyboardType }

    // 默认锁定 Shift 状态，如果取消锁定 Shift 状态，则需要切换键盘大小写
    if hamsterConfig?.Keyboard?.lockShiftState ?? true { return keyboardType }

    if let type = preferredAutocapitalizedKeyboardType { return type }
    if let type = preferredKeyboardTypeAfterAlphaTyping { return type }
    if let type = preferredKeyboardTypeAfterNonAlphaSpace { return type }
    return keyboardType
  }
}

private extension KeyboardContext {
  /// 首选自动大写键盘类型
  var preferredAutocapitalizedKeyboardType: KeyboardType? {
    guard isAutoCapitalizationEnabled else { return nil }
    guard let proxyType = autocapitalizationType else { return nil }
    guard keyboardType.isAlphabetic else { return nil }
    let uppercased = KeyboardType.alphabetic(.uppercased)
    let lowercased = KeyboardType.alphabetic(.lowercased)
    if locale.isRightToLeft { return lowercased }
    switch proxyType {
    case .allCharacters: return uppercased
    case .sentences: return textDocumentProxy.isCursorAtNewSentenceWithTrailingWhitespace ? uppercased : lowercased
    case .words: return textDocumentProxy.isCursorAtNewWord ? uppercased : lowercased
    default: return lowercased
    }
  }

  /// 首选在首字母输入后的键盘类型
  var preferredKeyboardTypeAfterAlphaTyping: KeyboardType? {
    guard keyboardType.isAlphabetic else { return nil }
    return .alphabetic(.lowercased)
  }

  /// 首选非字母类型键盘，在输入空格后的键盘类型
  var preferredKeyboardTypeAfterNonAlphaSpace: KeyboardType? {
    guard keyboardType == .numeric || keyboardType == .symbolic else { return nil }
    guard let before = textDocumentProxy.documentContextBeforeInput else { return nil }
    guard before.hasSuffix(" "), !before.hasSuffix("  ") else { return nil }
    keyboardType = .alphabetic(.lowercased)
    return preferredAutocapitalizedKeyboardType
  }
}
