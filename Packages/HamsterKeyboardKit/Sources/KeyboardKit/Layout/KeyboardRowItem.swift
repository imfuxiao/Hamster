//
//  KeyboardRowItem.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-05-08.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by types that represent an
 item in a kind of row, such as input sets, layout items etc.

 该协议可以通过表示某行中 item 的类型来实现，如 InputSetItem、KeyboardLayoutItem 等。

 The reason for having this protocol is mainly to have a way
 to share functionality. It is implemented by ``InputSetItem``
 and ``KeyboardLayoutItem`` and provide collection extension
 functions in `KeyboardRowItem+Collection`.

 制定此协议的原因主要是为了共享功能。
 它由 ``InputSetItem`` 和 ``KeyboardLayoutItem`` 实现，并在 `KeyboardRowItem+Collection` 中提供集合扩展函数。

 The reason to why not using `Identifiable` instead, is that
 the row ID may not be unique. The same item may appear many
 times in the same row.

 不使用 `Identifiable` 的原因是，rowId 可能不是唯一的。
 同一 item 可能会在同一行中出现多次。
 */
public protocol KeyboardRowItem {
  associatedtype ID: Equatable

  /**
   An ID that identifies the item in a row. Note that this
   is not necessarily unique.

   标识行中 item 的 ID。
   请注意，这不一定是唯一的。
   */
  var rowId: ID { get }
}
