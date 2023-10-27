//
//  KeyboardAppearance.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-10.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics
import UIKit

/**
 This protocol can be implemented by classes that can define
 styles and appearances for different parts of a keyboard.

 该协议可通过为键盘不同部分自定义样式和外观的类来实现。

 KeyboardKit will create a ``StandardKeyboardAppearance`` as
 the keyboard extension is started, then apply this instance
 to ``KeyboardInputViewController/keyboardAppearance``. This
 instance will then be used by default to determine how your
 appearance-based views will look.

 键盘扩展启动时，KeyboardKit 将创建一个 ``StandardKeyboardAppearance`` 实例，
 然后将该实例应用到 ``KeyboardInputViewController/keyboardAppearance`` 中。
 默认情况下，该实例将用于确定基于 KeyboardAppearance 协议的视图的外观。

 If you want to change the style of some buttons or callouts
 or change the the text or image to use for buttons, you can
 implement a custom keyboard appearance.

 如果要更改某些按钮或呼出的样式，或更改按钮使用的文本或图像，可以实现自定义键盘外观。

 You can create a custom implementation of this protocol, by
 inheriting and customizing the standard class or creating a
 new implementation from scratch. When you're implementation
 is ready, just replace the controller service with your own
 implementation to make the library use it instead.

 您可以通过继承和定制标准类或从头开始创建一个新的实现来创建该协议的自定义实现。
 当你的实现准备就绪时，只需用你自己的实现替换 controller 中的服务，就能让程序库使用它。
 */
public protocol KeyboardAppearance: AnyObject {
  /**
   The keyboard background style to apply to the keyboard.

   描述键盘的背景样式。
   */
  var backgroundStyle: KeyboardBackgroundStyle { get }

  /// 非标准键盘样式
  var nonStandardKeyboardStyle: NonStandardKeyboardStyle { get }

  /**
   The foreground color to apply to the keyboard, if any.

   应用于键盘的前景色（如果有）。
   */
  var foregroundColor: UIColor? { get }

  /// 候选栏样式
  var candidateBarStyle: CandidateBarStyle { get }

  /**
   The edge insets to apply to the entire keyboard.

   应用于整个键盘的边缘嵌入。
   */
  var keyboardEdgeInsets: UIEdgeInsets { get }

  // MARK: - Keys

  /**
   The button image to use for a certain `action`, if any.

   用于特定 `action` 的按键图像（如果有）。
   */
  func buttonImage(for action: KeyboardAction) -> UIImage?

  /**
   The scale factor to apply to a button image, if any.

   应用于按键图像的缩放因子（如果有）。
   */
  func buttonImageScaleFactor(for action: KeyboardAction) -> CGFloat

  /**
   The button style to use for a certain `action`, given a
   certain `isPressed` state.

   在给定的 `isPressed` 状态下，用于特定 `action` 的按键样式。
   */
  func buttonStyle(for action: KeyboardAction, isPressed: Bool) -> KeyboardButtonStyle

  /**
   在给定的 `isPressed` 状态下，用于特定 `key` 的按键样式。
   */
  func buttonStyle(for key: Key, isPressed: Bool) -> KeyboardButtonStyle

  /**
   The button text to use for a certain `action`, if any.

   用于特定 `action` 的按键文本（如果有）。
   */
  func buttonText(for action: KeyboardAction) -> String?

  // MARK: - Callouts

  /**
   The style to use for ``ActionCallout`` views.

   用于 ``ActionCallout`` 视图的样式。
   */
  var actionCalloutStyle: KeyboardActionCalloutStyle { get }

  /**
   The style to use for ``InputCallout`` views.

   用于 ``InputCallout`` 视图的样式。
   */
  var inputCalloutStyle: KeyboardInputCalloutStyle { get }

  /**
   The style to use for ``AutocompleteToolbar`` views.
   */
  var autocompleteToolbarStyle: AutocompleteToolbarStyle { get }
}
