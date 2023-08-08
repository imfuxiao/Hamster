//
//  StandardKeyboardLayoutProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This layout provider is initialized with a keyboard context,
 an input set provider and a list of localized providers.

 该布局 provider 通过 KeyboardContext、InputSetProvider 和 LocalizedProvider列表 进行初始化。

 If the ``keyboardContext`` locale matches the locale of any
 of the provided ``localizedProviders`` instances, then that
 provider will be used instead of the input set provider and
 the nested ``iPhoneProvider`` and ``iPadProvider`` keyboard
 layout providers. To modify the keyboard layout of a nested,
 localized keyboard layout provider, simply inject a new one
 for that locale.

 如果 ``keyboardContext`` 本地化语言与所提供的任何 ``localizedProviders`` 实例的本地化语言相匹配，
 则将使用该提供程序，而不是 InputSetProvider 以及嵌套的 `iPhoneProvider` 和 `iPadProvider` 键盘布局提供程序。
 要修改嵌套的 Local 的键盘布局 Provider 的键盘布局，只需为该 Local 注入一个新的 provider 即可。

 > Important: Since English is the standard language that is
 used to define input set and keyboard layout, this provider
 has no `English` provider in its standard list of localized
 providers, since that would cause the input set provider to
 always be ignored.

 > 重要：由于英语是用于定义输入集和键盘布局的标准语言，因此该 provider 的本地化提供程序标准列表中没有 `English` provider，
 > 因为这会导致 InputSetProvider 始终被忽略。
 */
open class StandardKeyboardLayoutProvider: KeyboardLayoutProvider {
  // MARK: - Properties

  /**
   The input set provider to use.

   使用的 InputSetProvider。

   > Important: This is deprecated and will be removed in KeyboardKit 7.0
   > 此功能已过时，将在 KeyboardKit 7.0 中移除。
   */
  public var inputSetProvider: InputSetProvider {
    didSet {
      iPadProvider.register(inputSetProvider: inputSetProvider)
      iPhoneProvider.register(inputSetProvider: inputSetProvider)
    }
  }

  /**
   The keyboard context to use.

   使用的键盘上下文。
   */
  public let keyboardContext: KeyboardContext

  /**
   The keyboard layout provider to use for iPad devices.

   用于 iPad 设备的键盘布局 provider。

   > Important: This is deprecated and will be removed in KeyboardKit 7.0
   > 此功能已过时，将在 KeyboardKit 7.0 中移除。
   */
  open lazy var iPadProvider = iPadKeyboardLayoutProvider(
    inputSetProvider: inputSetProvider)

  /**
   The keyboard layout provider to use for iPhone devices.

   供 iPhone 设备使用的键盘布局 provider。

   > Important: This is deprecated and will be removed in KeyboardKit 7.0
   > 此功能已过时，将在 KeyboardKit 7.0 中移除。
   */
  open lazy var iPhoneProvider = iPhoneKeyboardLayoutProvider(
    inputSetProvider: inputSetProvider)

  // MARK: - Initializations

  /**
   Create a standard keyboard layout provider.

   - Parameters:
     - keyboardContext: The keyboard context to use.
     - inputSetProvider: The input set provider to use.
   */
  public init(keyboardContext: KeyboardContext, inputSetProvider: InputSetProvider) {
    self.keyboardContext = keyboardContext
    self.inputSetProvider = inputSetProvider
  }

  // MARK: - Functions

  /**
   The keyboard layout to use for a certain context.

   在给定的上下文中使用的键盘布局。
   */
  open func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    keyboardLayoutProvider(for: context).keyboardLayout(for: context)
  }

  /**
   The keyboard layout provider to use for a given context.

   在给定的上下文中使用的键盘布局 provider。
   */
  open func keyboardLayoutProvider(for context: KeyboardContext) -> KeyboardLayoutProvider {
    return context.deviceType == .pad ? iPadProvider : iPhoneProvider
  }

  /**
   Register a new input set provider.

   注册新的输入集 provider。
   */
  open func register(inputSetProvider: InputSetProvider) {
    self.inputSetProvider = inputSetProvider
  }
}
