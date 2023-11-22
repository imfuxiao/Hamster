//
//  Color+Keyboard.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-20.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This protocol can be implemented by any type that should be
 able to access keyboard-specific colors.

 该协议可以由任何能够访问键盘特定颜色的类型来实现。

 This protocol is implemented by `UIColor`. This means that it
 is possible to use e.g. `UIColor.standardButtonBackground` to
 get the standard button background.

 该协议由 `UIColor` 实现。这意味着可以使用 `UIColor.standardButtonBackground` 等来获取标准按钮背景。

 The context-based color functions may look strange, but the
 reason for having them this way is that iOS gets an invalid
 color scheme when editing a text field with dark appearance.
 This causes iOS to set the extension's color scheme to dark
 even if the system color scheme is light.

 基于 context 的颜色功能可能看起来很奇怪，但之所以采用这种方式，是因为在编辑深色外观的文本字段时，iOS 会获取无效的配色方案。
 这会导致 iOS 将扩展的 color scheme 设置为深色，即使系统配色方案为浅色。

 To work around this, some colors have a temporary color set
 with a `ForColorSchemeBug` suffix that are semi-transparent
 white with an opacity that makes them look ok in both light
 and dark mode.

 为了解决这个问题，有些颜色设置了一个后缀名为 "ForColorSchemeBug "的临时颜色，这些颜色是半透明的白色，其不透明度使它们在暗色模式下都能正常显示。

 Issue report (also reported to Apple in Feedback Assistant):
 https://github.com/danielsaidi/KeyboardKit/issues/305
 */
public protocol KeyboardColorReader {}

public class HamsterUIColor: KeyboardColorReader {
  public static let shared = HamsterUIColor()

  private init() {}

  // MARK: - Properties

  /**
   This color can be used instead of `.clear` if the color
   should be registering touches and gestures.

   如果要注册触摸和手势，可以用这种颜色代替 `.clear`。

   This will be phased out. Instead of this, use a content
   shape within buttons and views that use touches.

   这将被逐步淘汰。取而代之的是在使用触摸的按钮和视图中使用内容形状。
   */
  public private(set) lazy var clearInteractable: UIColor = UIColor.white.withAlphaComponent(0.01)

  /**
   The standard background color of light keyboard buttons.

   浅色键盘按键的标准背景色。
   */
  public private(set) lazy var standardButtonBackground: UIColor = color(for: .standardButtonBackground)

  /**
   The standard background color of light keyboard buttons
   when accounting for the iOS dark mode bug.

   当考虑到 iOS 暗色模式 bug 时，浅色键盘按钮的标准背景颜色。
   */
  public private(set) lazy var standardButtonBackgroundForColorSchemeBug: UIColor = color(for: .standardButtonBackgroundForColorSchemeBug)

  /**
   The standard background color of light keyboard buttons
   in dark keyboard appearance.

   深色键盘外观中, 浅色键盘按钮的标准背景色。
   */
  public private(set) lazy var standardButtonBackgroundForDarkAppearance: UIColor = color(for: .standardButtonBackgroundForDarkAppearance)

  /**
   The standard foreground color of light keyboard buttons.

   浅色键盘按钮的标准前景色。
   */
  public private(set) lazy var standardButtonForeground: UIColor = color(for: .standardButtonForeground)

  /**
   The standard foreground color of light keyboard buttons
   in dark keyboard appearance.

   深色键盘外观中浅色键盘按钮的标准前景色。
   */
  public private(set) lazy var standardButtonForegroundForDarkAppearance: UIColor = color(for: .standardButtonForegroundForDarkAppearance)

  /**
   The standard shadow color of keyboard buttons.

   键盘按钮的标准阴影颜色。
   */
  public private(set) lazy var standardButtonShadow: UIColor = color(for: .standardButtonShadow)

  /**
   The standard background color of a dark keyboard button.

   深色键盘按钮的标准背景色。
   */
  // lazy var standardDarkButtonBackground: UIColor = HamsterUIColor.color(for: .standardDarkButtonBackground)
  public private(set) lazy var standardDarkButtonBackground: UIColor = .init(red: 0, green: 0, blue: 0, alpha: 0.15)

  /**
   The standard background color of a dark keyboard button
   when accounting for the iOS dark mode bug.

   当考虑到 iOS 暗色模式错误时，暗色键盘按钮的标准背景颜色。
   */
  public private(set) lazy var standardDarkButtonBackgroundForColorSchemeBug: UIColor = color(for: .standardDarkButtonBackgroundForColorSchemeBug)

  /**
   The standard background color of a dark keyboard button
   in dark keyboard appearance.

   深色键盘外观中深色键盘按钮的标准背景色。
   */
  public private(set) lazy var standardDarkButtonBackgroundForDarkAppearance: UIColor = color(for: .standardDarkButtonBackgroundForDarkAppearance)

  /**
   The standard foreground color of a dark keyboard button.

   深色键盘按钮的标准前景色。
   */
  public private(set) lazy var standardDarkButtonForeground: UIColor = color(for: .standardButtonForeground)

  /**
   The standard foreground color of a dark keyboard button
   in dark keyboard appearance.

   深色键盘外观中深色键盘按钮的标准前景色。
   */
  public private(set) lazy var standardDarkButtonForegroundForDarkAppearance: UIColor = color(for: .standardButtonForegroundForDarkAppearance)

  /**
   The standard keyboard background color.

   标准键盘背景色。
   */
  public private(set) lazy var standardKeyboardBackground: UIColor = color(for: .standardKeyboardBackground)

  /**
   The standard keyboard background color in dark keyboard
   appearance.

   深色键盘外观中的标准键盘背景色。
   */
  public private(set) lazy var standardKeyboardBackgroundForDarkAppearance: UIColor = color(for: .standardKeyboardBackgroundForDarkAppearance)

  // MARK: - Functions

  /**
   The standard background color of light keyboard buttons.

   浅色键盘按钮的标准背景色。
   */
  public func standardButtonBackground(for context: KeyboardContext) -> UIColor {
    context.hasDarkColorScheme ? self.standardButtonBackgroundForColorSchemeBug : self.standardButtonBackground
  }

  public func standardButtonBackground(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
    userInterfaceStyle == .dark ? self.standardButtonBackgroundForColorSchemeBug : self.standardButtonBackground
  }

  /**
   The standard foreground color of light keyboard buttons.

   浅色键盘按钮的标准前景色。
   */
  public func standardButtonForeground(for context: KeyboardContext) -> UIColor {
    context.hasDarkColorScheme ? self.standardButtonForegroundForDarkAppearance : self.standardButtonForeground
  }

  public func standardButtonForeground(for style: UIUserInterfaceStyle) -> UIColor {
    style == .dark ? self.standardButtonForegroundForDarkAppearance : self.standardButtonForeground
  }

  /**
   The standard shadow color of keyboard buttons.

   键盘按钮的标准阴影颜色。
   */
  public func standardButtonShadow(for context: KeyboardContext) -> UIColor {
    self.standardButtonShadow
  }

  /**
   The standard background color of dark keyboard buttons.

   深色键盘按钮的标准背景色。
   */
  public func standardDarkButtonBackground(for context: KeyboardContext) -> UIColor {
    context.hasDarkColorScheme ? self.standardDarkButtonBackgroundForColorSchemeBug : self.standardDarkButtonBackground
  }

  public func standardDarkButtonBackground(for style: UIUserInterfaceStyle) -> UIColor {
    style == .dark ? self.standardDarkButtonBackgroundForColorSchemeBug : self.standardDarkButtonBackground
  }

  /**
   The standard foreground color of dark keyboard buttons.

   深色键盘按钮的标准前景色。
   */
  public func standardDarkButtonForeground(for context: KeyboardContext) -> UIColor {
    context.hasDarkColorScheme ? self.standardDarkButtonForegroundForDarkAppearance : self.standardDarkButtonForeground
  }

  func color(for color: KeyboardColor) -> UIColor {
    color.color
  }
}
