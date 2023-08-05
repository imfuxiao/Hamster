//
//  InputSetRow.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-03.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This typealias represents a row of input set items.

 该类型别名代表 InputSetItem 的集合。
 */
public typealias InputSetRow = [InputSetItem]

public extension InputSetRow {
  /**
   Create an input row from a string, where each character
   is mapped to a ``InputSetItem``.

   从字符串创建 InputSetRow，其中每个字符都映射到一个 ``InputSetItem`` 。
   */
  init(chars: String) {
    self.init(chars: chars.chars)
  }

  /**
   Create an input row from an array, where each character
   is mapped to a ``InputSetItem``.

   由字符串数组创建 InputSetRow，其中数组中的每个字符串都映射到一个 ``InputSetItem``.
   */
  init(chars: [String]) {
    self = chars.map { InputSetItem($0) }
  }

  /**
   Create an input row from a lowercased and an uppercased
   string, where each char is mapped to a ``InputSetItem``.

   用小写字符串和大写字符串创建 InputSetRow，其中每个字符都被映射到一个 ``InputSetItem`` 中。

   Both arrays must contain the same amount of characters.

   两个数组必须包含相同数量的字符。
   */
  init(
    lowercased: String,
    uppercased: String
  ) {
    self.init(
      lowercased: lowercased.chars,
      uppercased: uppercased.chars
    )
  }

  /**
   Create an input row from a lowercased and an uppercased
   array, where each char is mapped to a ``InputSetItem``.

   用小写数组和大写数组创建 InputSetRow，其中每个字符都映射到一个 ``InputSetItem``.

   Both arrays must contain the same amount of characters.

   两个数组必须包含相同数量的字符。
   */
  init(lowercased: [String], uppercased: [String]) {
    // lowercased 数组和 uppercased 数组必须包含相同数量的字符
    assert(lowercased.count == uppercased.count, "The lowercased and uppercased string arrays must contain the same amount of characters")
    self = lowercased.enumerated().map {
      InputSetItem(
        neutral: lowercased[$0.offset],
        uppercased: uppercased[$0.offset],
        lowercased: lowercased[$0.offset]
      )
    }
  }

  /**
   Create an input row from phone and pad-specific strings,
   where each character is mapped to a ``InputSetItem``.

   从 phone 和 pad 特定的字符串创建 InputSetRow，其中每个字符都映射到一个 ``InputSetItem``。
   */
  init(
    phone: String,
    pad: String,
    deviceType: DeviceType = .current
  ) {
    self.init(chars: deviceType == .pad ? pad.chars : phone.chars)
  }

  /**
   Create an input row from phone and pad-specific strings,
   where each character is mapped to a ``InputSetItem``.

   从 phone 和 pad 特定字符串创建 InputSetRow，其中每个字符都映射到一个 ``InputSetItem``。
   */
  init(
    phone: [String],
    pad: [String],
    deviceType: DeviceType = .current
  ) {
    self.init(chars: deviceType == .pad ? pad : phone)
  }

  /**
   Create an input row from phone and pad-specific strings,
   where each character is mapped to a ``InputSetItem``.

   从 phone 和 pad 特定字符串创建 InputSetRow，其中每个字符都映射到一个 ``InputSetItem``。
   */
  init(
    phoneLowercased: String,
    phoneUppercased: String,
    padLowercased: String,
    padUppercased: String,
    deviceType: DeviceType = .current
  ) {
    self.init(
      lowercased: deviceType == .pad ? padLowercased.chars : phoneLowercased.chars,
      uppercased: deviceType == .pad ? padUppercased.chars : phoneUppercased.chars
    )
  }

  /**
   Create an input row from phone and pad-specific strings,
   where each character is mapped to a ``InputSetItem``.

   从 phone 和 pad 特定字符串创建 InputSetRow，其中每个字符都映射到一个 ``InputSetItem``。
   */
  init(
    phoneLowercased: [String],
    phoneUppercased: [String],
    padLowercased: [String],
    padUppercased: [String],
    deviceType: DeviceType = .current
  ) {
    self.init(
      lowercased: deviceType == .pad ? padLowercased : phoneLowercased,
      uppercased: deviceType == .pad ? padUppercased : phoneUppercased
    )
  }

  /**
   Get all input characters for a certain keyboard case.

   获取特定键盘状态小的所有输入字符。
   */
  func characters(for case: KeyboardCase = .lowercased) -> [String] {
    map { $0.character(for: `case`) }
  }
}
