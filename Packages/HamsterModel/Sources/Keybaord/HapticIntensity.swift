//
//  HapticIntensity.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 震动反馈强度
public enum HapticIntensity: Int, CaseIterable, Equatable, Identifiable {
  public var id: Int {
    return rawValue
  }

  case softImpact = 0
  case lightImpact = 1
  case rigidImpact = 2
  case mediumImpact = 3
  case heavyImpact = 4

  var text: String {
    switch self {
    case .softImpact:
      return "超轻"
    case .lightImpact:
      return "轻"
    case .rigidImpact:
      return "默认"
    case .mediumImpact:
      return "中"
    case .heavyImpact:
      return "强"
    }
  }

  func hapticFeedback() -> HapticFeedback {
    switch self {
    case .softImpact:
      return .softImpact
    case .lightImpact:
      return .lightImpact
    case .rigidImpact:
      return .rigidImpact
    case .mediumImpact:
      return .mediumImpact
    case .heavyImpact:
      return .heavyImpact
    }
  }
}
