//
//  KeyboardAction+KeyboardActionRows.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-07-04.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This typealias represents a ``KeyboardActions`` array.

 该类型别名代表一个 ``KeyboardActions`` 数组。

 The typealias makes it easier to create and handle keyboard
 action rows and collections.

 通过类型别名，可以更轻松地创建和处理键盘操作的行和集合。
 */
public typealias KeyboardActionRows = [KeyboardActions]

public extension KeyboardActionRows {
  /**
    Create keyboard action rows by mapping string arrays to
    a list of ``KeyboardAction/character(_:)`` actions.

   通过将字符串数组映射到 ``KeyboardAction/character(_:)`` 列表，创建键盘操作行。
   */
  init(characters: [[String]]) {
    self = characters.map { KeyboardActions(characters: $0) }
  }

  init(symbols: [[String]]) {
    self = symbols.map { KeyboardActions(symbols: $0) }
  }
}
