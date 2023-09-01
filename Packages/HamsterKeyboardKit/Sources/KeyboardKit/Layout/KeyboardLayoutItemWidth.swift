//
//  KeyboardLayoutWidth.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-21.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics

/**
 This enum describes various ways in which a keyboard layout
 can size its items.
 
 该枚举描述了在键盘布局调整 item 的大小的各种方式。
 */
public indirect enum KeyboardLayoutItemWidth: Equatable, Codable {
  /**
   Share the remaining width with other `.available` width
   items on the same row.
   
   同一行上的类型为 `.available` 的 item 共享剩余宽度。
   */
  case available
    
  /**
   This width can be used to give all input items the same
   width, based on the row with the smallest input width.
   
   根据同一行类型为 `input` 中宽度的最小值，作为这些 item 的宽度
   */
  case input
    
  /**
   Use a percentual width of the resulting `input` width.
   
   使用 `input` 类型宽度的百分比值作为 item 的宽度
   即 .inputPercentage 类型的宽度 = .input宽度 * percent
   */
  case inputPercentage(_ percent: CGFloat)
    
  /**
   Use a percentual width of the total available row width.
   
   使用行的总可用宽度的百分比作为 item 宽度。
   */
  case percentage(_ percent: CGFloat)
    
  /**
   Use a fixed width in points.
   
   使用 points 为单位的固定宽度。
   */
  case points(_ points: CGFloat)
}
