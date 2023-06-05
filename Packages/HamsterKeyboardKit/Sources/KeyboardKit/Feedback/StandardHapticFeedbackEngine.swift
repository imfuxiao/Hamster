//
//  StandardHapticFeedbackEngine.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This engine uses system features to trigger haptic feedback.
 It's the default ``HapticFeedback/engine`` on all platforms
 where it's supported.

 该引擎使用系统功能触发触觉反馈。在所有支持该引擎的平台上，它都是默认的 "HapticFeedback/engine"。

 You can use, modify and replace the ``shared`` engine. This
 lets you customize the global haptic feedback experience.

 您也可以使用、修改和替换 "shared" 引擎。这可以让你定制全局触觉反馈。

 Note that that haptic feedback requires full access.

 请注意，触觉反馈需要完全访问权限。
 */
open class StandardHapticFeedbackEngine: HapticFeedbackEngine {
  public init() {}

  private var notificationGenerator = UINotificationFeedbackGenerator()
  private var softImpactGenerator = UISelectionFeedbackGenerator()
  private var lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
  private var mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
  private var rigidImpactGenerator = UIImpactFeedbackGenerator(style: .rigid)
  private var heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
  private var selectionGenerator = UISelectionFeedbackGenerator()

  /**
   Prepare a certain haptic feedback type.

   某种触觉反馈类型的 prepare。
   */
  open func prepare(_ feedback: HapticFeedback) {
    switch feedback {
    case .error, .success, .warning: notificationGenerator.prepare()
    case .softImpact: softImpactGenerator.prepare()
    case .lightImpact: lightImpactGenerator.prepare()
    case .mediumImpact: mediumImpactGenerator.prepare()
    case .rigidImpact: rigidImpactGenerator.prepare()
    case .heavyImpact: heavyImpactGenerator.prepare()
    case .selectionChanged: selectionGenerator.prepare()
    case .none: return
    }
  }

  /**
   Trigger a certain haptic feedback type.

   某种触觉反馈类型的 trigger。
   */
  open func trigger(_ feedback: HapticFeedback) {
    switch feedback {
    case .error: triggerNotification(.error)
    case .success: triggerNotification(.success)
    case .warning: triggerNotification(.warning)
    case .softImpact: softImpactGenerator.selectionChanged()
    case .lightImpact: lightImpactGenerator.impactOccurred()
    case .mediumImpact: mediumImpactGenerator.impactOccurred()
    case .rigidImpact: rigidImpactGenerator.impactOccurred()
    case .heavyImpact: heavyImpactGenerator.impactOccurred()
    case .selectionChanged: selectionGenerator.selectionChanged()
    case .none: return
    }
  }
}

public extension StandardHapticFeedbackEngine {
  /**
   A shared instance that can be used from anywhere.

   可在任何地方使用的共享实例。
   */
  static var shared = StandardHapticFeedbackEngine()
}

private extension StandardHapticFeedbackEngine {
  func triggerNotification(_ notification: UINotificationFeedbackGenerator.FeedbackType) {
    notificationGenerator.notificationOccurred(notification)
  }
}
