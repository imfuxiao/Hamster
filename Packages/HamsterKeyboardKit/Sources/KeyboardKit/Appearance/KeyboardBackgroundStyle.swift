//
//  KeyboardBackgroundStyle.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-03-18.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This style defines the background of a keyboard.

 定义键盘的背景样式。

 This style has many components that can be used to create a
 background view that can then be added as a background to a
 keyboard view. The ``backgroundView`` property returns such
 a view, which applies all properties in a `ZStack`.

 该样式有许多组件，可用于创建背景视图，然后将其添加为键盘视图的背景。
 ``backgroundView`` 属性会返回这样一个视图，它应用了 `ZStack` 中的所有属性。

 You can modify the ``standard`` style to change the default,
 global background style.

 您可以修改 ``standard`` 样式，以更改默认的全局背景样式。
 */
public struct KeyboardBackgroundStyle: Equatable {
  /// A background color to apply.
  ///
  /// 要应用的背景颜色。
  public var backgroundColor: UIColor?

  /// A background gradient color set.
  ///
  /// 背景渐变色集
  public var backgroundGradient: [UIColor]?

  /// Optional image data that can be used to create a background image.
  ///
  /// 可选项，用于创建背景图片
  public var imageData: Data?

  /// An overlay color to apply.
  ///
  /// 可选项，叠加颜色。
  public var overlayColor: UIColor?

  /// An overlay gradient color set.
  ///
  /// 可选项，叠加渐变色集
  public var overlayGradient: [UIColor]?

  /**
   Create a background style with optional components.

   创建带有可选组件的背景样式。

   - Parameters:
     - backgroundColor: A background color to apply, by default `nil`.
     - backgroundGradient: A background gradient color set, by default `nil`.
     - imageData: Optional image data that can be used to create a background image, by default `nil`.
     - overlayColor: An overlay color to apply, by default `nil`.
     - overlayGradient: An overlay gradient color set, by default `nil`.
   */
  public init(
    backgroundColor: UIColor? = nil,
    backgroundGradient: [UIColor]? = nil,
    imageData: Data? = nil,
    overlayColor: UIColor? = nil,
    overlayGradient: [UIColor]? = nil
  ) {
    self.backgroundColor = backgroundColor
    self.backgroundGradient = backgroundGradient
    self.imageData = imageData
    self.overlayColor = overlayColor
    self.overlayGradient = overlayGradient
  }
}

public extension KeyboardBackgroundStyle {
  /**
   This standard style mimics the native iOS style.

   This can be set to change the standard value everywhere.
   */
  static var standard = KeyboardBackgroundStyle()

  /**
   Create a background style with a single color.

   创建单一颜色的背景样式。
   */
  static func color(_ color: UIColor) -> KeyboardBackgroundStyle {
    .init(backgroundColor: color)
  }

  /**
   Create a background style with a single image.

   使用单张图片创建背景样式。
   */
  static func image(_ data: Data) -> KeyboardBackgroundStyle {
    .init(imageData: data)
  }

  /**
   Create a background style with a vertical gradient.

   创建垂直渐变的背景样式。
   */
  static func verticalGradient(_ colors: [UIColor]) -> KeyboardBackgroundStyle {
    .init(backgroundGradient: colors)
  }
}

private extension KeyboardBackgroundStyle {
  func image(from data: Data?) -> UIImage? {
    guard let data else { return nil }
    return UIImage(data: data) ?? UIImage()
  }
}
