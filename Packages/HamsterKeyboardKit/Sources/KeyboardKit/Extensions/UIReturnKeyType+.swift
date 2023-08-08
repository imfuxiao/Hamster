//
//  UIReturnKeyType+.swift
//
//
//  Created by morse on 2023/8/8.
//

import UIKit

public extension UIReturnKeyType {
  /**
   The corresponding ``KeyboardReturnKeyType``.

   对应自定义的 ``KeyboardReturnKeyType`` 类型

   Return types that have no matching primary type will be
   mapped to ``KeyboardReturnKeyType/custom(title:)``.

   没有匹配的 Return 按键类型将被映射为 ``KeyboardReturnKeyType/custom(title:)``.
   */
  var keyboardReturnKeyType: KeyboardReturnKeyType {
    switch self {
    case .default: return .return
    case .done: return .done
    case .go: return .go
    case .google: return .custom(title: "Google")
    case .join: return .join
    case .next: return .next
    case .route: return .custom(title: "route")
    case .search: return .search
    case .send: return .send
    case .yahoo: return .custom(title: "Yahoo")
    case .emergencyCall: return .custom(title: "emergencyCall")
    case .continue: return .custom(title: "continue")
    @unknown default: return .custom(title: "unknown")
    }
  }
}
