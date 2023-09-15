//
//  KeyboardCase.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-07-04.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum lists the various shift states a keyboard can use.
 
 该 enum 列出了键盘可使用的各种 shift 状态。
 */
public enum KeyboardCase: String, Codable, Identifiable, Hashable {
  /**
   `.auto` is a transient state, that should automatically
   be replaced by another more apropriate case when typing.
   
   `.auto` 是一种瞬时态，在输入时应自动替换为另一种更合适的情况。
   */
  case auto
    
  /**
   `.capsLocked` is an uppercased state that should not be
   automatically adjusted when typing.
   
   `.capsLocked` 是一种大写状态，输入时不应自动调整。
   */
  case capsLocked
    
  /**
   `.lowercased` should follow the `autocapitalization` of
   the text document proxy.
   
   `.lowercased` 应遵循 UITextDocumentProxy 的 "autocapitalization" 属性。
   */
  case lowercased
    
  /**
   `.uppercased` should follow the `autocapitalization` of
   the text document proxy.
   
   `.uppercased` 应遵循 UITextDocumentProxy 的 "autocapitalization" 属性。
   */
  case uppercased
}

public extension KeyboardCase {
  /**
   The casing's unique identifier.
   
   KeyboardCase 的唯一标识符。
   */
  var id: String { rawValue }
    
  /**
   Whether or not the casing represents a lowercased case.
   
   KeyboardCase 是否小写字母状态。
   */
  var isLowercased: Bool {
    switch self {
    case .auto: return false
    case .capsLocked: return false
    case .lowercased: return true
    case .uppercased: return false
    }
  }
    
  /**
   Whether or not the casing represents an uppercased case.
   
   KeyboardCase 是否大写字母状态。
   */
  var isUppercased: Bool {
    switch self {
    case .auto: return false
    case .capsLocked: return true
    case .lowercased: return false
    case .uppercased: return true
    }
  }
}
