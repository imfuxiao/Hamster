//
//  ClassifySymbolKeyboardStyle.swift
//
//
//  Created by morse on 2023/10/20.
//

import UIKit

/// 非标准键盘样式（适用与分类符号键盘/Emoji键盘等）
public struct NonStandardKeyboardStyle {
  /// 背景色
  public var backgroundColor: UIColor?

  /// 按下时背景色
  public var pressedBackgroundColor: UIColor?

  /// 前景色
  public var foregroundColor: UIColor?

  /// 按下时前景色
  public var pressedForegroundColor: UIColor

  /// 边框颜色
  public var borderColor: UIColor?

  /// 底部阴影颜色
  public var shadowColor: UIColor

  /// 圆角半径
  public var cornerRadius: CGFloat

  init(
    backgroundColor: UIColor? = nil,
    pressedBackgroundColor: UIColor? = nil,
    foregroundColor: UIColor? = nil,
    pressedForegroundColor: UIColor,
    borderColor: UIColor? = nil,
    shadowColor: UIColor,
    cornerRadius: CGFloat
  ) {
    self.backgroundColor = backgroundColor
    self.pressedBackgroundColor = pressedBackgroundColor
    self.foregroundColor = foregroundColor
    self.pressedForegroundColor = pressedForegroundColor
    self.borderColor = borderColor
    self.shadowColor = shadowColor
    self.cornerRadius = cornerRadius
  }
}
