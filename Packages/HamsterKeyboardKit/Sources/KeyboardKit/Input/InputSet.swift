//
//  InputSet.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-07-03.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 An input set defines the input keys on a keyboard. The keys
 can then be used to create a keyboard layout, which defines
 the full set of keys, including the surrounding system keys.

 The most flexible way to generate an input set is to use an
 ``InputSetProvider``.

 InputSet 定义了键盘上的输入键。然后，这些按键可用于创建键盘布局，该布局定义了整套按键，包括系统按键。

 生成 InputSet 最灵活的方法是使用 ``InputSetProvider``。
 */
public protocol InputSet: Equatable {
  var rows: InputSetRows { get }
}

/**
 This input set can be used in alphabetic keyboards.

 该输入集可用于字母键盘。
 */
public struct AlphabeticInputSet: InputSet {
  /**
   The rows in the input set.
   */
  public var rows: InputSetRows

  /**
   Create an alphabetic input set.
   */
  public init(rows: InputSetRows) {
    self.rows = rows
  }
}

/**
 This input set can used in numeric keyboards.

 该输入集可用于数字键盘。
 */
public struct NumericInputSet: InputSet {
  public var rows: InputSetRows
  public init(rows: InputSetRows) {
    self.rows = rows
  }
}

/**
 This input set can be used in symbolic keyboards.

 该输入集可用于符号键盘。
 */
public struct SymbolicInputSet: InputSet {
  public var rows: InputSetRows
  public init(rows: InputSetRows) {
    self.rows = rows
  }
}
