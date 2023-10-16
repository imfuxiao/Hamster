//
//  ChineseKeyboardLayoutProvider.swift
//
//
//  Created by morse on 2023/9/2.
//

import Foundation

/**
 此键盘布局 Provider 可用于创建标准的中文键盘布局。
 */
open class ChineseKeyboardLayoutProvider: SystemKeyboardLayoutProvider, KeyboardLayoutProviderProxy {
  /**
   The layout provider to use for iPad devices.
   */
  public lazy var iPadProvider = iPadChineseKeyboardLayoutProvider(
    inputSetProvider: inputSetProvider
  )

  /**
   The layout provider to use for iPhone devices.
   */
  public lazy var iPhoneProvider = iPhoneChineseKeyboardLayoutProvider(
    inputSetProvider: inputSetProvider
  )

  /**
   Create an English keyboard layout provider.

   - Parameters:
     - inputSetProvider: The input set provider to use, by default ``EnglishInputSetProvider``.
   */
  override public init(inputSetProvider: InputSetProvider = ChineseInputSetProvider()) {
    super.init(inputSetProvider: inputSetProvider)
  }

  /**
   The layout keyboard to use for a given keyboard context.
   */
  override open func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    keyboardLayoutProvider(for: context).keyboardLayout(for: context)
  }

  /**
   Register a new input set provider.

   注册新的 InputSetProvider。
   */
  override open func register(inputSetProvider: InputSetProvider) {
    self.inputSetProvider = inputSetProvider
    iPadProvider.register(inputSetProvider: inputSetProvider)
    iPhoneProvider.register(inputSetProvider: inputSetProvider)
  }

  /**
   The keyboard layout provider to use for a given context.
   */
  open func keyboardLayoutProvider(for context: KeyboardContext) -> KeyboardLayoutProvider {
    switch context.deviceType {
    case .phone: return iPhoneProvider
    case .pad: return iPadProvider
    default: return iPhoneProvider
    }
  }
}
