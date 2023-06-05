//
//  InputSetProviderBased.swift
//  KeyboardKit
//
//
//  Created by Daniel Saidi on 2022-12-29.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol is implemented by services that may depend on
 an ``InputSetProvider`` and must be reconfigured when a new
 input set provider is being used.

 该协议由可能依赖于 ``InputSetProvider`` 的服务实现，
 并且在使用新的 InputSetProvider 时必须重新配置。

 > Note: This will no longer be needed when the library uses
 keyboard layout providers that use their own providers. The
 context provider can then be removed and this as well.

 > Note：当库使用的 KeyboardLayoutProvider 是自己实现的 Provider 时，将不再需要此功能。
 > 这样就可以移除上下文提供程序，也可以移除此程序。
 */
public protocol InputSetProviderBased {
  /**
   Register a new input set provider.
   */
  func register(inputSetProvider: InputSetProvider)
}
