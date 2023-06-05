//
//  Locale+.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2022-12-20.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension Locale {
  /**
   Whether or not the locale prefers to replace any single
   alternate ending quotation delimiters with begin ones.

   本地语言是否倾向于用开头引号替换任何单引号结尾分隔符。
   */
  var prefersAlternateQuotationReplacement: Bool {
    if identifier.hasPrefix("en") { return false }
    return true
  }
}

// MARK: - 通过 Local 获取本地语言行及字符的方向

public extension Locale {
  /**
   Get the character direction of the locale.

   获取本地语言的字符方向。
   */
  var characterDirection: LanguageDirection {
    Locale.characterDirection(forLanguage: languageCode ?? "")
  }

  /**
   Whether or not the line direction is `.bottomToTop`.

   行方向是否为 `.bottomToTop`。
   */
  var isBottomToTop: Bool {
    lineDirection == .bottomToTop
  }

  /**
   Whether or not the line direction is `.topToBottom`.

   行方向是否为 `.topToBottom`。
   */
  var isTopToBottom: Bool {
    lineDirection == .topToBottom
  }

  /**
   Whether or not the character direction is `.leftToRight`.

   字符方向是否为 `.leftToRight`。
   */
  var isLeftToRight: Bool {
    characterDirection == .leftToRight
  }

  /**
   Whether or not the character direction is `.rightToLeft`.

   字符方向是否为 `.rightToLeft`。
   */
  var isRightToLeft: Bool {
    characterDirection == .rightToLeft
  }

  /**
   Get the line direction of the locale.

   获取本地语言的行方向。
   */
  var lineDirection: LanguageDirection {
    Locale.lineDirection(forLanguage: languageCode ?? "")
  }
}
