//
//  HamsterHapticFeedbackEngine.swift
//  Hamster
//
//  Created by morse on 2023/6/20.
//

import UIKit

class HamsterHapticFeedbackEngine {
  public init() {}

  private var notificationGenerator = UINotificationFeedbackGenerator()
  private var lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
  private var softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)
  private var rigidImpactGenerator = UIImpactFeedbackGenerator(style: .rigid)
  private var mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
  private var heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
  private var selectionGenerator = UISelectionFeedbackGenerator()

  /**
   Prepare a certain haptic feedback type.
   */
  func prepare(_ feedback: HamsterHapticFeedback) {
    switch feedback {
    case .error, .success, .warning: notificationGenerator.prepare()
    case .lightImpact: lightImpactGenerator.prepare()
    case .mediumImpact: mediumImpactGenerator.prepare()
    case .heavyImpact: heavyImpactGenerator.prepare()
    case .softImpact: softImpactGenerator.prepare()
    case .rigidImpact: rigidImpactGenerator.prepare()
    case .selectionChanged: selectionGenerator.prepare()
    case .none: return
    }
  }

  /**
   Trigger a certain haptic feedback type.
   */
  func trigger(_ feedback: HamsterHapticFeedback) {
    switch feedback {
    case .error: triggerNotification(.error)
    case .success: triggerNotification(.success)
    case .warning: triggerNotification(.warning)
    case .selectionChanged: selectionGenerator.selectionChanged()
    case .softImpact: softImpactGenerator.impactOccurred()
    case .lightImpact: lightImpactGenerator.impactOccurred()
    case .rigidImpact: rigidImpactGenerator.impactOccurred()
    case .mediumImpact: mediumImpactGenerator.impactOccurred()
    case .heavyImpact: heavyImpactGenerator.impactOccurred()
    case .none: return
    }
  }
}

extension HamsterHapticFeedbackEngine {
  /**
   A shared instance that can be used from anywhere.
   */
  static var shared = HamsterHapticFeedbackEngine()
}

private extension HamsterHapticFeedbackEngine {
  func triggerNotification(_ notification: UINotificationFeedbackGenerator.FeedbackType) {
    notificationGenerator.notificationOccurred(notification)
  }
}
