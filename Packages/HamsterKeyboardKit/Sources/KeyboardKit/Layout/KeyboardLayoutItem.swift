//
//  KeyboardLayoutItem.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-03.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics
import UIKit

/**
 Keyboard layout items are used to define a ``KeyboardAction``,
 a ``KeyboardLayoutItemSize`` and edge insets for an item in
 a system keyboard layout.

 KeyboardLayoutItem 用于为系统键盘布局中的 item 定义 ``KeyboardAction``、``KeyboardLayoutItemSize`` 和 UIEdgeInsets。

 Note that insets must be applied within the button tap area,
 to avoid a dead tap areas between the keyboard buttons.

 请注意，必须在按钮点击区域内应用 UIEdgeInsets，以避免键盘按钮之间出现点按死区。
 */
public struct KeyboardLayoutItem: Equatable, KeyboardRowItem {
  /**
   The keyboard action that should be used for the item.

   应用于该 item 的键盘操作。
   */
  public var action: KeyboardAction

  /**
   The layout size that should be used for the item.

   应用于该 item 的布局尺寸
   */
  public var size: KeyboardLayoutItemSize

  /**
   The item insets that should be used for the item.

   应用于该 item 的 UIEdgeInsets。
   */
  public var insets: UIEdgeInsets

  /// 该 item 的划动配置
  public var swipes: [KeySwipe]

  /// 自定义键盘对应 Key
  public var key: Key? = nil

  /**
   The row ID the is used to identify the item in a row.

   rowID 用于标识同行中的 item。
   注意：不是同行中的唯一值，可能重复
   */
  public var rowId: KeyboardAction { action }

  /**
   Create a new layout item.

   - Parameters:
     - action: The keyboard action that should be used for the item.
     - size: The layout size that should be used for the item.
     - insets: The item insets that should be used for the item.
   */
  // TODO: 这里添加 swipe 属性
  public init(
    action: KeyboardAction,
    size: KeyboardLayoutItemSize,
    insets: UIEdgeInsets,
    swipes: [KeySwipe] = [],
    key: Key? = nil
  ) {
    self.action = action
    self.size = size
    self.insets = insets
    self.swipes = swipes
    self.key = key
  }
}

/**
 This typealias represents a list of ``KeyboardLayoutItem``s.

 该类型别名代表一个 ``KeyboardLayoutItem`` 的 list。
 */
public typealias KeyboardLayoutItemRow = [KeyboardLayoutItem]

/**
 This typealias represents a list of ``KeyboardLayoutItemRow``
 values that make up a keyboard's rows.

 此类型别名表示组成键盘行的 ``KeyboardLayoutItemRow`` 的 list。
 */
public typealias KeyboardLayoutItemRows = [KeyboardLayoutItemRow]
