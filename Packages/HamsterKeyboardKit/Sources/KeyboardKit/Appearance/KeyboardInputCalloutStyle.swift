//
//  KeyboardInputCalloutStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics

/**
 This style can be applied to ``InputCalloutView``s to customize
 things like the callout style, padding, font etc.
 
 此样式可应用于 ``InputCalloutView`` 视图，自定义诸如呼出样式、填充、字体等。
 
 You can modify the ``standard`` style to change the default,
 global style of all ``InputCallout`` views that use it.
 
 您可以修改 ``standard`` 样式，以更改使用该样式的所有 ``InputCalloutView`` 视图的默认全局样式。
 
 The ``calloutSize`` specifies a **minimum** size to use for
 the callout. If other factors, like button size, curve size,
 padding etc. requires the callout to be larger, the size is
 ignored and the required size will be applied.
 
 ``calloutSize`` 指定了呼出的最小尺寸。如果其他因素（如按钮大小、曲线大小、填充等）
 需要更大的呼出尺寸，则会忽略该尺寸，并应用所需的尺寸。
 
 Note that the ``calloutSize`` height will be ignored when a
 phone displays a callout in landscape, since callouts can't
 expand beyond the edges of a keyboard extension.
 
 请注意，当手机横向显示呼出时，`calloutSize`` 高度将被忽略，因为呼出无法扩展到键盘扩展区域的边缘之外。
 */
public struct KeyboardInputCalloutStyle: Equatable {
  /**
   The callout style to use.
   
   使用的呼出样式。
   */
  public var callout: KeyboardCalloutStyle
  
  /**
   The padding to apply to the callout content.
   
   应用于呼出内容的填充。
   */
  public var calloutPadding: CGFloat
  
  /**
   The minimum size of the callout above the button area.
   
   按钮区域上方呼出视图的最小尺寸。
   
   If other factors, like button size, curve size, padding
   etc. requires the callout to be larger, this is ignored.
   
   如果其他因素（如按钮大小、曲线大小、填充等）要求呼出的尺寸更大，则会被忽略。
   */
  public var calloutSize: CGSize
  
  /**
   The font to use in the callout.
   
   呼出中使用的字体。
   */
  public var font: KeyboardFont
  
  /**
   Create an input callout style.
   
   创建输入呼出样式。
     
   - Parameters:
     - callout: The callout style to use, by default ``KeyboardCalloutStyle/standard``.
     - calloutPadding: The padding to apply to the callout content, by default `2`.
     - calloutSize: The minimum size of the callout bubble, by default `.largeTitle .light`.
     - font: The font to use in the callout.
   */
  public init(
    callout: KeyboardCalloutStyle = .standard,
    calloutPadding: CGFloat = 2,
    calloutSize: CGSize = CGSize(width: 0, height: 55),
    font: KeyboardFont = .init(.largeTitle, .light)
  ) {
    self.callout = callout
    self.calloutPadding = calloutPadding
    self.calloutSize = calloutSize
    self.font = font
  }
}

// MARK: - Standard Style

public extension KeyboardInputCalloutStyle {
  /**
   This standard style mimics the native iOS style.

   This can be set to change the standard value everywhere.
   */
  static var standard = KeyboardInputCalloutStyle()
}
