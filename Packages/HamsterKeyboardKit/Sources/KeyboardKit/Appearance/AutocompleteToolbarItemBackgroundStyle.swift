//
//  AutocompleteToolbarItemBackgroundStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-10-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This style can be applied to customize the appearance of an
 ``AutocompleteToolbarItem``s background.

 可用于自定义 ``AutocompleteToolbarItem`` 的背景样式。

 You can modify the ``standard`` style to change the default,
 global style of all highlighted autocomplete items.

 您可以修改 ``standard`` 样式，以更改所有高亮显示自动完成项的默认全局样式。
 */
public struct AutocompleteToolbarItemBackgroundStyle: Equatable {
  /**
   The background color to use.

   使用的背景颜色。
   */
  public var color: UIColor

  /**
   The corner radius to use.

   使用的圆角半径。
   */
  public var cornerRadius: CGFloat

  /**
   Create an autocomplete toolbar item style.

   - Parameters:
     - color: The background color to use, by default `.white.opacity(0.5)`.
     - cornerRadius: The corner radius to use, by default `4`.
   */
  public init(color: UIColor = .white.withAlphaComponent(0.5), cornerRadius: CGFloat = 4) {
    self.color = color
    self.cornerRadius = cornerRadius
  }
}

public extension AutocompleteToolbarItemBackgroundStyle {
  /**
   This standard style mimics the native iOS style.

   This can be set to change the standard value everywhere.
   */
  static var standard = AutocompleteToolbarItemBackgroundStyle()
}

extension AutocompleteToolbarItemBackgroundStyle {
  /**
   This internal style is only used in previews.
   */
  static var preview1 = AutocompleteToolbarItemBackgroundStyle(
    color: .purple.withAlphaComponent(0.3),
    cornerRadius: 20)

  /**
   This internal style is only used in previews.
   */
  static var preview2 = AutocompleteToolbarItemBackgroundStyle(
    color: .orange.withAlphaComponent(0.8),
    cornerRadius: 10)
}
