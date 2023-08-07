//
//  InputSetProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to provide various ``InputSet`` values.

 该协议可由任何可用于提供各种 ``InputSet`` 值的类实现。

 KeyboardKit will create a ``StandardInputSetProvider`` when
 the keyboard extension is started, then apply that instance
 to ``KeyboardInputViewController/inputSetProvider`` and use
 it by default when generating input sets.

 键盘扩展(keyboard extension)启动后，KeyboardKit 将创建一个 ``StandardInputSetProvider`` 实例，
 然后将该实例应用到 ``KeyboardInputViewController/inputSetProvider`` 中，并在生成 InputSet 时默认使用该实例。

 You can create a custom implementation of this protocol, by
 inheriting and customizing the standard class or creating a
 new implementation from scratch. When you're implementation
 is ready, just replace the controller service with your own
 implementation to make the library use it instead.

 您可以通过继承和定制标准类或从头开始创建一个新的实现来创建该协议的自定义实现。
 当你的实现准备就绪时，只需用你自己的实现替换controller service，就能让程序库使用它。
 */
public protocol InputSetProvider: AnyObject {
  /**
   The input set to use for alphabetic keyboards.

   用于字母键盘的 InputSet。
   */
  var alphabeticInputSet: AlphabeticInputSet { get }

  /**
   The input set to use for numeric keyboards.

   数字键盘使用的 InputSet。
   */
  var numericInputSet: NumericInputSet { get }

  /**
   The input set to use for symbolic keyboards.

   符号键盘使用的 InputSet。
   */
  var symbolicInputSet: SymbolicInputSet { get }
}
