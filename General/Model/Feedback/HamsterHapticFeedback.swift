//
//  HapticFeedback.swift
//  Hamster
//
//  Created by morse on 2023/6/20.
//

import Foundation

enum HamsterHapticFeedback: String, CaseIterable, Codable, Equatable, Identifiable {
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

extension HamsterHapticFeedback {
  /**
   The unique feedback identifier.
   */
  var id: String { rawValue }

  /**
   The engine that will be used to trigger haptic feedback.
   */
  static let engine: HamsterHapticFeedbackEngine = .init()

  /**
   Prepare the haptic feedback, using the shared engine.
   */
  func prepare() {
    Self.engine.prepare(self)
  }

  /**
   Trigger the feedback, using the shared feedback engine.
   */
  func trigger() {
    Self.engine.trigger(self)
  }
}
