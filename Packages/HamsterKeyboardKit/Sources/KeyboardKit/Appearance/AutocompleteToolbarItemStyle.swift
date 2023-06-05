//
//  AutocompleteToolbarItemStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-10-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This style can be applied to ``AutocompleteToolbarItem``s.
 
 此样式可应用于 ``AutocompleteToolbarItem``s.
 
 You can modify the ``standard`` style to change the default,
 global style of all ``AutocompleteToolbarItem``s.
 
 您可以修改 ``standard`` 样式，以更改所有 ``AutocompleteToolbarItem`` 的默认全局样式。
 */
public struct AutocompleteToolbarItemStyle: Equatable {
  /**
   The font to use for the title text.
   
   标题文本使用的字体。
   */
  public var titleFont: KeyboardFont
    
  /**
   The color to use for the title text.
   
   标题文本使用的颜色。
   */
  public var titleColor: UIColor
    
  /**
   The font to use for the subtitle text.
   
   副标题文本使用的字体。
   */
  public var subtitleFont: KeyboardFont
    
  /**
   The color to use for the subtitle text.
   
   副标题文本使用的颜色。
   */
  public var subtitleColor: UIColor
  
  /**
   Create an autocomplete toolbar item style.
     
   - Parameters:
     - titleFont: The font to use for the title text, by default `.body`.
     - titleColor: The color to use for the title text, by default `.label`.
     - subtitleFont: The font to use for the subtitle text, by default `.footnote`.
     - subtitleColor: The color to use for the subtitle text, by default `.secondaryLabel`.
   */
  public init(
    titleFont: KeyboardFont = .body,
    titleColor: UIColor = .label,
    subtitleFont: KeyboardFont = .footnote,
    subtitleColor: UIColor = .secondaryLabel)
  {
    self.titleFont = titleFont
    self.titleColor = titleColor
    self.subtitleFont = subtitleFont
    self.subtitleColor = subtitleColor
  }
}

public extension AutocompleteToolbarItemStyle {
  /**
   This standard style mimics the native iOS style.
   
   该标准样式模仿 iOS 原生样式。

   This can be set to change the standard value everywhere.
   
   在任何地方都可以修改标准值。
   */
  static var standard = AutocompleteToolbarItemStyle()
}

extension AutocompleteToolbarItemStyle {
  /**
   This internal style is only used in previews.
   */
  static var preview1 = AutocompleteToolbarItemStyle(
    titleFont: .callout,
    titleColor: .red,
    subtitleFont: .body,
    subtitleColor: .yellow)
    
  /**
   This internal style is only used in previews.
   */
  static var preview2 = AutocompleteToolbarItemStyle(
    titleFont: .footnote,
    titleColor: .blue,
    subtitleFont: .headline,
    subtitleColor: .purple)
}
