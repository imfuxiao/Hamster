//
//  HamsterHapticFeedback.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation

public enum HapticFeedback: String, CaseIterable, Codable, Equatable, Identifiable {
  case

    /// Represents feedback for an error event.
    error,

    /// Represents feedback for a successful event.
    success,

    /// Represents feedback for a warning event.
    warning,

    softImpact,

    /// Represents light impact feedback.
    lightImpact,

    rigidImpact,

    /// Represents medium impact feedback.
    mediumImpact,

    /// Represents heavy impact feedback.
    heavyImpact,

    /// Represents feedback when a selection changes.
    selectionChanged,

    /// Can be used to disable feedback.
    none
}

public extension HapticFeedback {
  /**
   The unique feedback identifier.
   */
  var id: String { rawValue }
}
