//
//  KeyboardLayout.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-07-03.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 A keyboard layout defines all available keyboard actions on
 a keyboard, as well as their size.

 KeyboardLayout 定义了键盘上所有可用的键盘操作及其大小。

 A keyboard layout most often consists of several input rows
 where the input buttons are surrounded by system buttons on
 either or both sides, as well as a bottom row, with a large
 space button and several system buttons.

 键盘布局通常包括几行输入键，输入键的两侧或其中一侧被系统按键包围，
 还有一排底键，其中有一个大空格键和几个系统按键。

 The most flexible way to generate a keyboard layout is with
 a ``KeyboardLayoutProvider``.

 生成键盘布局最灵活的方法是使用``KeyboardLayoutProvider``。
 */
public class KeyboardLayout {
  // MARK: - Properties

  /// 自定义键盘对象
  public var customKeyboard: Keyboard?

  /**
   The layout item rows to show in the keyboard.

   要在键盘中显示的 item 全部行。
   */
  public var itemRows: KeyboardLayoutItemRows

  /**
   The ideal item height, which can be used if you want to
   quickly add new items to the layout.

   理想的 item 高度，如果您想快速在布局添加新的 item，可以使用该高度。
   */
  public var idealItemHeight: Double

  /**
   The ideal item inserts. This can be used if you want to
   quickly add new items to the layout.

   理想的 item 的 UIEdgeInsets。如果您想快速将新 item 添加到布局中，可以使用该值。
   */
  public var idealItemInsets: UIEdgeInsets

  /**
   This `CGFloat` typealias makes it easier to see where a
   total width is expected.

   这种 `CGFloat` 类型别名可以更轻松地查看预期的总宽度。
   */
  public typealias TotalWidth = CGFloat

  /**
   This cache is used to avoid having to recalculate width
   information over and over.

   Input 按键宽度缓存, 避免重复计算按键宽度
   */
  var widthCache = [TotalWidth: CGFloat]()

  // MARK: - Initializations

  /**
    Create a new layout with the provided `rows`.

    使用提供的 `rows` 创建新布局。

    - Parameters:
      - itemRows: The layout item rows to show in the keyboard.
                  键盘中要显示的布局项行。
      - idealItemHeight: An optional, ideal item height, otherwise picked from the first item.
                         可选的，理想的 item 高度，否则从第一个 item 中挑选。
      - idealItemInsets: An optional, ideal item inset value, otherwise picked from the first item.
                         可选的， 理想的 item 嵌入值，否则从第一个 item 中挑选。
      - customKeyboard: 可选项，自定义键盘对象
   */
  public init(
    itemRows rows: KeyboardLayoutItemRows,
    idealItemHeight height: Double? = nil,
    idealItemInsets insets: UIEdgeInsets? = nil,
    customKeyboard: Keyboard? = nil
  ) {
    self.itemRows = rows
    self.idealItemHeight = height ?? Self.resolveIdealItemHeight(for: rows)
    self.idealItemInsets = insets ?? Self.resolveIdealItemInsets(for: rows)
    self.customKeyboard = customKeyboard
  }
}

public extension KeyboardLayout {
  /**
   Get the bottom item row index.

   获取键盘最下面一行的索引。
   */
  var bottomRowIndex: Int {
    itemRows.count - 1
  }

  /**
   Get the system action items at the bottom row.

   获取键盘最下面一行中 item 的 KeyboardAction 为系统操作的全部 item 列表

   */
  var bottomRowSystemItems: [KeyboardLayoutItem] {
    if bottomRowIndex < 0 { return [] }
    return itemRows[bottomRowIndex].filter {
      $0.action.isSystemAction
    }
  }

  /**
   Whether or not the bottom row has a keyboard switcher.

   最下面一行是否有键盘切换器。
   */
  func hasKeyboardSwitcher(for type: KeyboardType) -> Bool {
    guard let row = itemRows.last else { return false }
    return row.contains { $0.action.isKeyboardTypeAction(.emojis) }
  }

  /**
   Calculate the width of an input key given a `totalWidth`.

   在给定`totalWidth`的情况下计算 .input 类型按键的最小宽度。

   This will find the smallest required input width in all
   rows, which can then be applied to all input keys. This
   value will then be cached for the `totalWidth`, so that
   it doesn't have to be calculated again.

   这将找出所有行中所需的最小输入宽度，然后将其应用于所有输入键。
   然后，该值将缓存到 `totalWidth` 中，这样就无需再次计算。
   */
  func inputWidth(
    for totalWidth: TotalWidth
  ) -> CGFloat {
    if let result = widthCache[totalWidth] { return result }
    let result = itemRows
      .compactMap { $0.inputWidth(for: totalWidth) }
      .min() ?? 0
    widthCache[totalWidth] = result
    return result
  }

  /**
   Get the bottom row system items.

   根据提供的 `KeyboardAction` 新建键盘最下面一行的 item。

   This function will use the first ``bottomRowSystemItems``
   as item template if you don't provide a template. If no
   template is found, the function will return `nil` since
   it lacks information to create a valid item.

   该函数将使用 ``bottomRowSystemItems`` 的第一个 item 作为新建 item 的模板。
   如果找不到模板，函数将返回`nil`，因为它缺乏创建有效 item 的信息。
   */
  func tryCreateBottomRowItem(
    for action: KeyboardAction
  ) -> KeyboardLayoutItem? {
    guard let template = bottomRowSystemItems.first else { return nil }
    return KeyboardLayoutItem(
      action: action,
      size: template.size,
      insets: template.insets,
      swipes: []
    )
  }
}

private extension KeyboardLayout {
  /// 确定理想 item 高度
  static func resolveIdealItemHeight(for rows: KeyboardLayoutItemRows) -> Double {
    let item = rows.flatMap { $0 }.first
    return Double(item?.size.height ?? .zero)
  }

  /// 确定理想 item 的 UIEdgeInsets
  static func resolveIdealItemInsets(for rows: KeyboardLayoutItemRows) -> UIEdgeInsets {
    let item = rows.flatMap { $0 }.first
    return item?.insets ?? UIEdgeInsets()
  }
}

private extension KeyboardLayoutItemRow {
  /// 判断行中 item 的声明性的宽度是否具有.input类型
  var hasInputWidth: Bool {
    contains { $0.size.width == .input }
  }

  /// 计算行中类型为 .input 类型的宽度
  func inputWidth(for totalWidth: CGFloat) -> CGFloat? {
    guard hasInputWidth else { return nil }
    // 获取类型为 .percentage 和 .points 总宽度
    let taken = reduce(0) { $0 + $1.allocatedWidth(for: totalWidth) }
    // 获取剩余可分配的宽度
    let remaining = totalWidth - taken
    // 获取类型 .input 和 .inputPercentage 的总百分比
    // 其中 .input 类型为 1， .inputPercentage 类型为实际百分比
    let totalRefPercentage = reduce(0) { $0 + $1.inputPercentageFactor }

    // 为 .input 类型计算宽度
    // 分子分母都 * UIScreen.main.scale 用于精确小数点位数
    return CGFloat.rounded(remaining / totalRefPercentage)
  }
}

private extension KeyboardLayoutItem {
  /// 在给定总宽度下，根据 item 的声明性宽度类型, 分配实际宽度
  func allocatedWidth(for totalWidth: CGFloat) -> CGFloat {
    switch size.width {
    case .available: return 0
    case .input: return 0
    case .inputPercentage: return 0
    case .percentage(let percentage): return totalWidth * percentage
    case .points(let points): return points
    }
  }

  /// input的百分比系数
  var inputPercentageFactor: CGFloat {
    switch size.width {
    case .available: return 0
    case .input: return 1
    case .inputPercentage(let percentage): return percentage
    case .percentage: return 0
    case .points: return 0
    }
  }
}

public extension CGFloat {
  static func rounded(_ measurement: CGFloat) -> CGFloat {
    return (measurement * UIScreen.main.scale) / UIScreen.main.scale
  }
}
