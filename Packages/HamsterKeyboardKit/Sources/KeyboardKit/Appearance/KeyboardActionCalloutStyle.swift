//
//  KeyboardActionCalloutStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This style can be applied to ``ActionCalloutView`` to customize
 things like the callout style, padding, font etc.
 
 此样式可应用于 ``ActionCalloutView`` 以自定义呼出样式、填充、字体等。
 
 You can modify the ``standard`` style to change the default,
 global style of all ``ActionCallout`` views that use it.
 
 您可以修改 ``standard`` 样式，以更改使用该样式的所有 ``ActionCalloutView`` 视图的默认全局样式。
 */
public struct KeyboardActionCalloutStyle: Equatable {
  /**
   The callout style to use.
   */
  public var callout: KeyboardCalloutStyle
    
  /**
   The font to use in the callout.
   */
  public var font: KeyboardFont
    
  /**
   The max size of the callout buttons.
   */
  public var maxButtonSize: CGSize
    
  /**
   The background color of the selected item.
   */
  public var selectedBackgroundColor: UIColor

  /**
   The foreground color of the selected item.
   */
  public var selectedForegroundColor: UIColor

  /**
   The vertical offset to apply to the callout.
   */
  public var verticalOffset: CGFloat
    
  /**
   The vertical padding to apply to text in the callout.
   */
  public var verticalTextPadding: CGFloat
  
  /**
   Create an action callout style.
     
   - Parameters:
     - callout: The callout style to use, by default ``KeyboardCalloutStyle/standard``.
     - font: The font to use in the callout, by default `.standardFont`.
     - maxButtonSize: The max button size, by default a `50` point square.
     - selectedBackgroundColor: The background color of the selected item, by default `.blue`.
     - selectedForegroundColor: The foreground color of the selected item, by default `.white`.
     - verticalOffset: The vertical offset of the action callout, by default `20` points on iPad devices and `0` otherwise.
     - verticalTextPadding: The vertical padding to apply to text in the callout, by default `6`.
   */
  public init(
    callout: KeyboardCalloutStyle = .standard,
    font: KeyboardFont = .init(.title3),
    maxButtonSize: CGSize = CGSize(width: 50, height: 50),
    selectedBackgroundColor: UIColor? = nil,
    selectedForegroundColor: UIColor? = nil,
    verticalOffset: CGFloat? = nil,
    verticalTextPadding: CGFloat = 6
  ) {
    self.callout = callout
    self.font = font
    self.maxButtonSize = maxButtonSize
    self.selectedBackgroundColor = selectedBackgroundColor ?? .blue
    self.selectedForegroundColor = selectedForegroundColor ?? .white
    let standardVerticalOffset: CGFloat = DeviceType.current == .pad ? 20 : 0
    self.verticalOffset = verticalOffset ?? standardVerticalOffset
    self.verticalTextPadding = verticalTextPadding
  }
}

// MARK: - Standard Style

public extension KeyboardActionCalloutStyle {
  /**
   This standard style mimics the native iOS style.

   This can be set to change the standard value everywhere.
   */
  static var standard = KeyboardActionCalloutStyle()
}
