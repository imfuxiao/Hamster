//
//  KeyboardButtonBorderStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-09-09.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This style defines the border of a keyboard key.
 
 此样式定义键盘按键的边框。
 
 You can modify the ``standard`` style to change the default,
 global style of all system keyboard buttons.
 
 您可以修改 ``standard`` 样式，以更改所有系统键盘按键的默认全局样式。
 */
public struct KeyboardButtonBorderStyle: Equatable {
  /**
   The color of the border.
   
   边框的颜色。
   */
  public var color: UIColor
    
  /**
   The size of the border.
   
   边框的大小。
   */
  public var size: CGFloat
  
  /**
   Create a system keyboard button border style.
   
   创建系统键盘按键边框样式。
     
   - Parameters:
     - color: The color of the border, by default `.clear`.
     - size: The size of the border, by default `0`.
   */
  public init(
    color: UIColor = .clear,
    size: CGFloat = 0
  ) {
    self.color = color
    self.size = size
  }
}

public extension KeyboardButtonBorderStyle {
  /**
   This style applies no border.
   
   这种样式没有边框。
   */
  static var noBorder = KeyboardButtonBorderStyle()
    
  /**
   This standard style mimics the native iOS style.
   
   这种标准样式模仿 iOS 原生样式。

   This can be set to change the standard value everywhere.
   
   可以修改此值来更改各处的标准值。
   */
  static var standard = KeyboardButtonBorderStyle()
}
