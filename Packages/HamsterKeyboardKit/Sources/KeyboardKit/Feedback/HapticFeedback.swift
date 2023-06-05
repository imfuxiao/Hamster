//
//  HamsterHapticFeedback.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation

public enum HapticFeedback: String, CaseIterable, Codable, Equatable, Identifiable {
  /// Represents feedback for an error event.
  ///
  /// 代表对错误事件的反馈。
  case error

  /// Represents feedback for a successful event.
  ///
  /// 代表对成功事件的反馈。
  case success

  /// Represents feedback for a warning event.
  ///
  /// 表示对警告事件的反馈。
  case warning

  /// Represents soft impact feedback.
  ///
  /// 表示最弱的触觉反馈
  case softImpact

  /// Represents light impact feedback.
  ///
  /// 代表轻微触觉反馈。
  case lightImpact

  /// Represents medium impact feedback.
  ///
  /// 代表中等影响反馈。
  case mediumImpact

  /// Represents rigid impact feedback.
  ///
  /// 表示刚性(比 medium 稍重)的触觉反馈
  case rigidImpact

  /// Represents heavy impact feedback.
  ///
  /// 表示重的触觉反馈
  case heavyImpact

  /// Represents feedback when a selection changes.
  ///
  /// 代表选择改变时的反馈。
  case selectionChanged

  /// Can be used to disable feedback.
  ///
  /// 可用于禁用反馈。
  case none
}

// MARK: - Public Functions

public extension HapticFeedback {
  /**
   The unique feedback identifier.
   */
  var id: String { rawValue }

  /**
   The engine that will be used to trigger haptic feedback.

   用于触发触觉反馈的引擎。
   */
  static var engine: HapticFeedbackEngine = StandardHapticFeedbackEngine.shared

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
