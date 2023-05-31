//
//  KeyboardType.swift
//  Hamster
//
//  Created by morse on 19/5/2023.
//

import Foundation
import KeyboardKit

enum keyboardCustomType: String, CaseIterable, Equatable {
  // "拼音九宫格"
  case chineseNineGrid

  // "数字九宫格"
  case numberNineGrid

  // 符号
  case symbol

  var buttonName: String {
    switch self {
    case .numberNineGrid: return "123"
    case .symbol: return "符"
    default: return ""
    }
  }

  var keyboardType: KeyboardType {
    return .custom(named: self.rawValue)
  }

  var keyboardAction: KeyboardAction? {
    switch self {
    case .numberNineGrid: return .keyboardType(.custom(named: self.rawValue))
    case .symbol: return .keyboardType(.custom(named: self.rawValue))
    default: return nil
    }
  }
}

extension KeyboardType {
  /**
   * 是否数字九宫格
   */
  var isNumberNineGrid: Bool {
    switch self {
    case .custom(let name):
      if name == keyboardCustomType.numberNineGrid.rawValue {
        return true
      }
      return false
    default: return false
    }
  }

  /**
   * 是否数字九宫格
   */
  var isCustomSymbol: Bool {
    switch self {
    case .custom(let name):
      if name == keyboardCustomType.symbol.rawValue {
        return true
      }
      return false
    default: return false
    }
  }
}
