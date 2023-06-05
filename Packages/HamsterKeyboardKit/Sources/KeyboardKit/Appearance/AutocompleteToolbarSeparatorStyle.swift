//
//  AutocompleteToolbarSeparatorStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-10-05.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This style can be applied to ``AutocompleteToolbarSeparator``
 views to control the color and width of the separator line.
 
 此样式可应用于 ``AutocompleteToolbarSeparator`` 视图，以控制分隔线的颜色和宽度。
 
 You can modify the ``standard`` style to change the default,
 global style of all ``AutocompleteToolbarSeparator``s.
 
 您可以修改 ``standard`` 样式，以更改所有 ``AutocompleteToolbarSeparator`` 的默认全局样式。
 */
public struct AutocompleteToolbarSeparatorStyle: Equatable {
  /**
   The color of the separator.
   
   分隔线的颜色。
   */
  public var color: UIColor
    
  /**
   The height of the separator, it any.
   
   分隔线的高度。
   */
  public var height: CGFloat
    
  /**
   The width of the separator.
   
   分隔线的宽度。
   */
  public var width: CGFloat
  
  /**
   Create an autocomplete toolbar separator style.
     
   - Parameters:
     - color: The color of the separator, by default `.secondarySystemBackground.opacity(0.5)`.
     - width: The width of the separator, by default `1`.
     - height: An height of the separator, by default `30`.
   */
  public init(
    color: UIColor = .secondarySystemBackground.withAlphaComponent(0.5),
    width: CGFloat = 1,
    height: CGFloat = 30)
  {
    self.color = color
    self.width = width
    self.height = height
  }
}

public extension AutocompleteToolbarSeparatorStyle {
  /**
   This standard style mimics the native iOS style.
   
   这种标准样式模仿 iOS 原生样式。

   This can be set to change the standard value everywhere.
   
   你可以在任何地方修改此标准值
   */
  static var standard = AutocompleteToolbarSeparatorStyle()
}

extension AutocompleteToolbarSeparatorStyle {
  /**
   This internal style is only used in previews.
   */
  static var preview1 = AutocompleteToolbarSeparatorStyle(
    color: .red,
    width: 2)
    
  /**
   This internal style is only used in previews.
   */
  static var preview2 = AutocompleteToolbarSeparatorStyle(
    color: .green,
    width: 5,
    height: 20)
}
