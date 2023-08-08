//
//  KeyboardFontType.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-03-30.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This enum defines supported keyboard fonts.

 该枚举定义了支持的键盘字体类型。

 This type makes it possible to use fonts in `Codable` types.

 这种类型使在 `Codable` 类型中使用字体成为可能。
 */
public enum KeyboardFontType: Codable, Equatable {
  case body
  case callout
  case caption
  case caption2
  case custom(_ name: String, size: CGFloat)
  case footnote
  case headline
  case largeTitle
  case subheadline
  case system(size: CGFloat)
  case title
  case title2
  case title3
}

public extension KeyboardFontType {
  /// Get the native font for the font type.
  ///
  /// 获取字体类型的本地字体。
  var font: UIFont {
    switch self {
    case .body: return UIFont.preferredFont(forTextStyle: .body)
    case .callout: return UIFont.preferredFont(forTextStyle: .callout)
    case .caption: return UIFont.preferredFont(forTextStyle: .caption1)
    case .caption2: return UIFont.preferredFont(forTextStyle: .caption2)
    case .footnote: return UIFont.preferredFont(forTextStyle: .footnote)
    case .headline: return UIFont.preferredFont(forTextStyle: .headline)
    case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle)
    case .subheadline: return UIFont.preferredFont(forTextStyle: .subheadline)
    case .system(let size): return UIFont.systemFont(ofSize: size)
    case .title: return UIFont.preferredFont(forTextStyle: .title1)
    case .title2: return UIFont.preferredFont(forTextStyle: .title2)
    case .title3: return UIFont.preferredFont(forTextStyle: .title3)
    case .custom(let name, let size):
      // TODO: 当自定义字体不存在时，返回系统字体
      if let font = UIFont(name: name, size: size) {
        return font
      }
      return .systemFont(ofSize: size)
    }
  }
}
