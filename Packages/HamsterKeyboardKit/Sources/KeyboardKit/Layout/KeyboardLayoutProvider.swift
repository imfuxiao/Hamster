//
//  KeyboardLayoutProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to generate a ``KeyboardLayout`` for a certain context.
 
 该协议可由任何可用于为特定上下文生成 ``KeyboardLayout`` 的类实现。
 
 KeyboardKit will create a ``StandardKeyboardLayoutProvider``
 instance when the keyboard extension is started, then apply
 it to ``KeyboardInputViewController/keyboardLayoutProvider``
 and use it by default when generating keyboard layouts.
 
 键盘扩展启动时，KeyboardKit 将创建一个 ``StandardKeyboardLayoutProvider`` 实例，
 然后将其应用到 ``KeyboardInputViewController/keyboardLayoutProvider`` 中，
 并在生成键盘布局时默认使用该实例。
 
 You can create a custom implementation of this protocol, by
 inheriting and customizing the standard class or creating a
 new implementation from scratch. When you're implementation
 is ready, just replace the controller service with your own
 implementation to make the library use it instead.
 
 您可以通过继承和定制标准类或从头开始创建一个新的实现来创建该协议的自定义实现。
 当你的实现准备就绪时，只需用你自己的实现替换 controler 中的服务，就能让程序库使用它。
 */
public protocol KeyboardLayoutProvider: AnyObject, InputSetProviderBased {
  /**
   The layout keyboard to use for a given keyboard context.
   */
  func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout
}
