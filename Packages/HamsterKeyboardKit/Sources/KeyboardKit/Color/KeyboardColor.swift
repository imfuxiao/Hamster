//
//  KeyboardColor.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-13.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This enum defines raw, keyboard-specific asset-based colors.

 该枚举定义了基于 asset 的特定键盘原始颜色。

 Although you can use this type directly, you should instead
 use the ``KeyboardColorReader`` protocol, to get extensions
 that build on these colors. `UIColor` already implements this
 protocol, so you can use it directly.

 虽然可以直接使用此类型，但应使用 ``KeyboardColorReader`` 协议，以获得基于这些颜色的扩展。
 `UIColor` 已经实现了该协议，因此可以直接使用。
 */
public enum KeyboardColor: String, CaseIterable, Identifiable {
  case standardButtonBackground
  case standardButtonBackgroundForColorSchemeBug
  case standardButtonBackgroundForDarkAppearance
  case standardButtonForeground
  case standardButtonForegroundForDarkAppearance
  case standardButtonShadow
  case standardDarkButtonBackground
  case standardDarkButtonBackgroundForColorSchemeBug
  case standardDarkButtonBackgroundForDarkAppearance
  case standardKeyboardBackground
  case standardKeyboardBackgroundForDarkAppearance
}

public extension KeyboardColor {
  /**
   The bundle to use to retrieve bundle-based color assets.

   用于检索基于 bundle 的颜色 asserts 的 bundle。

   You should only override this value when the entire set
   of colors should be loaded from another bundle.

   只有在从另一个颜色 bundle 加载整套颜色时，才可以覆盖此值。
   */
  static var bundle: Bundle = .hamsterKeyboard
}

public extension KeyboardColor {
  /**
   The color's unique identifier.

   颜色的唯一标识符。
   */
  var id: String { rawValue }

  /**
   The color value.
   */
  static var cacheColor = [String: UIColor]()
  var color: UIColor {
    if let color = Self.cacheColor[resourceName] {
      return color
    }
    let color = UIColor(named: resourceName, in: Self.bundle, compatibleWith: .none)!
    Self.cacheColor[resourceName] = color
    return color
  }

  /**
   The color asset name in the bundle asset catalog.

   bundle 中 assert 目录中的颜色名称。
   */
  var resourceName: String { rawValue }
}
