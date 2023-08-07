//
//  File.swift
//
//
//  Created by morse on 2023/8/6.
//

import UIKit

/**
 This enum defines supported keyboard font weights.

 此枚举定义支持的键盘字体粗细。

 This type makes it possible to use fonts in `Codable` types.

 这种类型使在 `Codable` 类型中使用字体成为可能。
 */
public enum KeyboardFontWeight: Codable, Equatable {
  case black
  case bold
  case heavy
  case light
  case medium
  case regular
  case semibold
  case thin
  case ultraLight
}

public extension KeyboardFontWeight {
  /// Get the native font weight for the weight.
  ///
  /// 获取系统字体Wight类型。
  var fontWeight: UIFont.Weight {
    switch self {
    case .black: return .black
    case .bold: return .bold
    case .heavy: return .heavy
    case .light: return .light
    case .medium: return .medium
    case .regular: return .regular
    case .semibold: return .semibold
    case .thin: return .thin
    case .ultraLight: return .ultraLight
    }
  }
}

public extension UIFont.Weight {
  var keyboardWeight: KeyboardFontWeight {
    switch self {
    case .black: return .black
    case .bold: return .bold
    case .heavy: return .heavy
    case .light: return .light
    case .medium: return .medium
    case .regular: return .regular
    case .semibold: return .semibold
    case .thin: return .thin
    case .ultraLight: return .ultraLight
    default: return .regular
    }
  }
}
