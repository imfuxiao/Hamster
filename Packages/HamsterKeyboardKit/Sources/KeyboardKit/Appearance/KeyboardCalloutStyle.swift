//
//  KeyboardCalloutStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-07.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This struct can be used to style callout views, which are a
 type of view that is presented above a keyboard button, e.g.
 when a user types or long presses a key to get more actions.
 
 该 struct 可用于 ``CalloutView`` 视图，这是一种显示在键盘按钮上方的视图，
 例如当用户键入或长按某个键以获取更多操作时。
 
 You can modify the ``standard`` style to change the default,
 global style of all callout views.
 
 您可以修改 ``standard`` 样式，以更改所有 ``CalloutView`` 视图的默认全局样式。
 */
public struct KeyboardCalloutStyle: Equatable {
  /**
   The background color of the entire callout.
   
   整个呼出视图的背景颜色。
   */
  public var backgroundColor: UIColor
    
  /**
   The border color of the entire callout.
   
   整个呼出视图的边框颜色。
   */
  public var borderColor: UIColor
    
  /**
   The corner radius of the button overlay.
   
   呼出视图上按键的圆角半径。
   */
  public var buttonCornerRadius: CGFloat
    
  /**
   The inset to apply to the part of the callout that will
   overlap the tapped button.
   
   应用于与点击按键重叠的呼出部分的嵌入。
     
   This must be used in a `SystemKeyboard`, where a button
   has an intrinsic padding, which cause the buttons to be
   larger than the visual area.
   
   此功能必须在 "系统键盘" 中使用，因为按钮有固有的填充，会导致按钮大于可视区域。
   */
  public var buttonInset: UIEdgeInsets
    
  /**
   The corner radius of the callout edges.
   
   呼出视图边缘的圆角半径。
   */
  public var cornerRadius: CGFloat
    
  /**
   The size of the curve that links the button overlay and
   the callout bubble.
   
   连接按键与呼出视图之间的曲线的大小。
   */
  public var curveSize: CGSize
    
  /**
   The shadow of the entire callout.
   
   整个呼出视图的阴影颜色。
   */
  public var shadowColor: UIColor
    
  /**
   The shadow radius of the entire callout.
   
   整个呼出视图的阴影半径。
   */
  public var shadowRadius: CGFloat
    
  /**
   The text color to use in the callout.
   
   呼出视图中使用的文字颜色。
   */
  public var textColor: UIColor
  
  /**
   Create a callout style.
     
   When customizing these values, note that some are meant
   to fit the context in which a callout is presented, e.g.
   ``buttonCornerRadius``, which should use the same value
   as the button that the callout is presented over.
   
   在自定义这些值时，请注意有些值是为了与显示呼出的上下文相匹配，
   例如 ``buttonCornerRadius``，它应使用与呼出所显示的按钮相同的值。
     
   Only customize the parameters you need to customize and
   use the default values for all other parameters.
   
   只定制需要定制的参数，其他参数均使用默认值。
     
   - Parameters:
     - backgroundColor: The background color of the entire callout, by default `.standardButtonBackground`.
     - borderColor: The border color of the entire callout, by default transparent `.black`.
     - buttonCornerRadius: The corner radius of the callout edges, by default `4`.
     - buttonInset: The inset to apply to the button overlay, by default transparent `.zero`.
     - cornerRadius: The corner radius of the callout edges, by default transparent `10`.
     - curveSize: The size of the curve that links the button overlay and callout, by default transparent `8x15`.
     - shadowColor: The shadow of the entire callout, by default transparent transparent `.black`.
     - shadowRadius: The shadow radius of the entire callout, by default transparent `5`.
     - textColor: The text color to use in the callout, by default `.primary`.
   */
  public init(
    backgroundColor: UIColor = HamsterUIColor.shared.standardButtonBackground,
    borderColor: UIColor = UIColor.black.withAlphaComponent(0.5),
    buttonCornerRadius: CGFloat = 5,
    buttonInset: UIEdgeInsets = .zero,
    cornerRadius: CGFloat = 10,
    curveSize: CGSize = CGSize(width: 8, height: 15),
    shadowColor: UIColor = UIColor.black.withAlphaComponent(0.1),
    shadowRadius: CGFloat = 5,
    textColor: UIColor = .label
  ) {
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.buttonCornerRadius = buttonCornerRadius
    self.buttonInset = buttonInset
    self.cornerRadius = cornerRadius
    self.curveSize = curveSize
    self.shadowColor = shadowColor
    self.shadowRadius = shadowRadius
    self.textColor = textColor
  }
}

public extension KeyboardCalloutStyle {
  /**
   This standard style mimics the native iOS style.

   This can be set to change the standard value everywhere.
   */
  static var standard = KeyboardCalloutStyle()
}

extension KeyboardCalloutStyle {
  /**
   This internal style is only used in previews.
   */
  static var preview1 = KeyboardCalloutStyle(
    backgroundColor: .red,
    borderColor: .white,
    buttonCornerRadius: 10,
    shadowColor: .green,
    shadowRadius: 3,
    textColor: .black
  )
    
  /**
   This internal style is only used in previews.
   */
  static var preview2 = KeyboardCalloutStyle(
    backgroundColor: .green,
    borderColor: .white,
    buttonCornerRadius: 20,
    shadowColor: .black,
    shadowRadius: 10,
    textColor: .red
  )
}
