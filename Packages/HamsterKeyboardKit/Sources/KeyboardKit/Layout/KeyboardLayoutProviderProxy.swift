//
//  DeviceKeyboardLayoutProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-16.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol extends ``KeyboardLayoutProvider`` with a way
 for a layout provider to resolve various providers based on
 a ``KeyboardContext`` instance.

 此协议扩展了 ``KeyboardLayoutProvider``，
 为布局 provider 提供了一种根据 ``KeyboardContext``实例解析各种 provider 的方法。

 This is for instance used to let a single provider use many
 nested providers and select one depending on the context.

 例如，这可以让单个 KeyboardLayoutProvider 实例使用多个嵌套 provider，并根据上下文选择其中一个。
 */
public protocol KeyboardLayoutProviderProxy: KeyboardLayoutProvider {
  /**
   The keyboard layout provider to use for a given context.

   在给定上下文中使用的键盘布局提供程序。
   */
  func keyboardLayoutProvider(for context: KeyboardContext) -> KeyboardLayoutProvider
}
