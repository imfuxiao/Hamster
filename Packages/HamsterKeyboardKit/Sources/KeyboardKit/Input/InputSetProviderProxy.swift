//
//  File.swift
//
//
//  Created by morse on 2023/9/2.
//

import Foundation

/// InputSetProvider 协议代理，支持根据 keyboardContext 切换不同的 InputSetProvider
public protocol InputSetProviderProxy: InputSetProvider {
  func provider(for context: KeyboardContext) -> InputSetProvider
}
