//
//  HapticIntensity.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation
import UIKit

/// 震动反馈强度
public enum HapticIntensity: Int, CaseIterable, Hashable, Identifiable {
  public var id: Int {
    return rawValue
  }

  case softImpact = 0
  case lightImpact = 1
  case rigidImpact = 2
  case mediumImpact = 3
  case heavyImpact = 4

  public var text: String {
    switch self {
    case .softImpact:
      return "超轻"
    case .lightImpact:
      return "轻"
    case .rigidImpact:
      return "默认"
    case .mediumImpact:
      return "较强"
    case .heavyImpact:
      return "强"
    }
  }

  public func feedbackStyle() -> UIImpactFeedbackGenerator.FeedbackStyle {
    switch self {
    case .softImpact:
      return .soft
    case .lightImpact:
      return .light
    case .rigidImpact:
      return .rigid
    case .mediumImpact:
      return .medium
    case .heavyImpact:
      return .heavy
    }
  }
}
