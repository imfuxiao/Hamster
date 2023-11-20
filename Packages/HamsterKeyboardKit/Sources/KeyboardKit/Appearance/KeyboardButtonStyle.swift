//
//  KeyboardButtonStyle.swift
//
//
//  Created by morse on 2023/8/6.
//

import UIKit

/**
 KeyboardButtonStyle 定义了键盘按键的样式

 该类型没有 "standard(标准)" 样式，因为标准样式取决于很多因素， 如按钮类型、布局配置等。
 相反，可以使用 ``KeyboardAppearance`` 来解决某些操作的样式问题。

 此 struct 参考 KeyboardKit 中的 KeyboardButtonStyle
 */
public struct KeyboardButtonStyle: Equatable {
  /**
   The background color to apply to the button.

   按键的背景颜色。
   */
  public var backgroundColor: UIColor?

  /**
   The foreground color to apply to the button.

   按键的前景颜色。
   */
  public var foregroundColor: UIColor?

  /// 划动显示前景颜色
  public var swipeForegroundColor: UIColor?

  /**
   The font to apply to the button.

   应用于按键的字体。
   */
  // public var font: KeyboardFont?
  public var font: UIFont?

  /// 按键上划动显示的字体
  // public var swipeFont: KeyboardFont?
  public var swipeFont: UIFont?

  /**
   The corner radius to apply to the button.

   按键的圆角半径
   */
  public var cornerRadius: CGFloat?

  /**
   The border color to apply to the button.

   按键的边框颜色。
   */
  public var borderColor: UIColor? {
    didSet {
      guard borderColor != nil, borderSize == nil else { return }
      borderSize = 1
    }
  }

  /**
   The border size to apply to the button.

   按键的边框大小。
   */
  public var borderSize: CGFloat? {
    didSet {
      guard borderSize != nil, borderColor == nil else { return }
      borderColor = .black
    }
  }

  /**
   The border style to apply to the button.

   按键的边框样式
   */
  public var border: KeyboardButtonBorderStyle? {
    get {
      guard let borderSize, let borderColor else { return nil }
      return .init(color: borderColor, size: borderSize)
    }
    set {
      borderColor = newValue?.color
      borderSize = newValue?.size
    }
  }

  /**
   The shadow color to apply to the button.

   按键的阴影颜色。
   */
  public var shadowColor: UIColor? {
    didSet {
      guard shadowColor != nil, shadowSize == nil else { return }
      shadowSize = 1
    }
  }

  /**
   The shadow size to apply to the button.

   按键的阴影大小。
   */
  public var shadowSize: CGFloat? {
    didSet {
      guard shadowSize != nil, shadowColor == nil else { return }
      shadowColor = HamsterUIColor.shared.standardButtonShadow
    }
  }

  /**
   The shadow style to apply to the button.

   按键阴影样式
   */
  public var shadow: KeyboardButtonShadowStyle? {
    get {
      guard let shadowSize, let shadowColor else { return nil }
      return .init(color: shadowColor, size: shadowSize)
    } set {
      shadowColor = newValue?.color
      shadowSize = newValue?.size
    }
  }

  /**
   The color to overlay the background color when pressed.

   按键按下时覆盖背景色的颜色。
   */
  public var pressedOverlayColor: UIColor?

  /**
   Create a system keyboard Key style.

   - Parameters:
     - backgroundColor: The background color to apply to the button, by default `nil`.
                        按键的背景颜色，默认为 "nil"。
     - foregroundColor: The foreground color to apply to the button, by default `nil`.
                        按键的前景颜色，默认为 "nil"。
     - font: The font to apply to the button, by default `nil`.
             应用于按键的字体，默认为 `nil`。
     - cornerRadius: The corner radius to apply to the button, by default `nil`.
                     应用于按键的圆角半径，默认为 `nil`。
     - border: The border style to apply to the button, by default `nil`.
               应用于按键的边框样式，默认为 `nil`。
     - shadow: The shadow style to apply to the button, by default `nil`.
               应用于按键的阴影样式，默认为 `nil`。
     - pressedOverlayColor: The color to overlay the background color when pressed, by default `nil`.
                            按键按下时覆盖背景色的颜色，默认为 `nil`。
   */
  public init(
    backgroundColor: UIColor? = nil,
    foregroundColor: UIColor? = nil,
    swipeForegroundColor: UIColor? = nil,
//    font: KeyboardFont? = nil,
//    swipeFont: KeyboardFont? = nil,
    font: UIFont? = nil,
    swipeFont: UIFont? = nil,
    cornerRadius: CGFloat? = nil,
    border: KeyboardButtonBorderStyle? = nil,
    shadow: KeyboardButtonShadowStyle? = nil,
    pressedOverlayColor: UIColor? = nil
  ) {
    self.backgroundColor = backgroundColor
    self.foregroundColor = foregroundColor
    self.swipeForegroundColor = swipeForegroundColor
    self.font = font
    self.swipeFont = swipeFont
    self.cornerRadius = cornerRadius
    self.borderColor = border?.color
    self.borderSize = border?.size
    self.shadowColor = shadow?.color
    self.shadowSize = shadow?.size
    self.pressedOverlayColor = pressedOverlayColor
  }
}

public extension KeyboardButtonStyle {
  /**
   Override this style with another style. This will apply
   all non-optional properties from the provided style.

   用另一种样式覆盖此样式。这将应用所提供样式的所有非选项属性。
   */
  func extended(with style: KeyboardButtonStyle) -> KeyboardButtonStyle {
    var result = self
    result.backgroundColor = style.backgroundColor ?? backgroundColor
    result.foregroundColor = style.foregroundColor ?? foregroundColor
    result.font = style.font ?? font
    result.cornerRadius = style.cornerRadius ?? cornerRadius
    result.border = style.border ?? border
    result.shadow = style.shadow ?? shadow
    return result
  }

  /**
   A spacer button style means that the button will not be
   visually detectable, but still rendered.

   间隔按钮样式意味着该按钮在视觉上无法检测到，但仍会呈现。
   */
  static let spacer = KeyboardButtonStyle(
    backgroundColor: .clear,
    foregroundColor: .clear,
    font: UIFont.preferredFont(forTextStyle: .body),
    cornerRadius: 0,
    border: .noBorder,
    shadow: .noShadow
  )
}
