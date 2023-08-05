//
//  KeyboardLayoutItemSize.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-03.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics

/**
 This struct provides the size of a keyboard layout item. It
 has a regular height, but a declarative width.

 该结构提供了键盘布局 item 的尺寸。
 它有一个常规高度，但有一个声明性的宽度。
 */
public struct KeyboardLayoutItemSize: Equatable {
  /**
   Create a new layout item size.

   创建新的布局 item 尺寸。

   - Parameters:
     - width: The declarative width of the item.
              item 的声明性宽度。
     - height: The fixed height of the item.
               item 的固定高度
   */
  public init(
    width: KeyboardLayoutItemWidth,
    height: CGFloat
  ) {
    self.width = width
    self.height = height
  }

  /**
   The declarative width of the item.

   item 的声明性宽度。
   */
  public var width: KeyboardLayoutItemWidth

  /**
   The fixed height of the item.

   item 的固定高度。
   */
  public var height: CGFloat
}
