//
//  HapticIntensity+.swift
//
//
//  Created by morse on 2023/8/7.
//

import Foundation

public extension HapticIntensity {
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
