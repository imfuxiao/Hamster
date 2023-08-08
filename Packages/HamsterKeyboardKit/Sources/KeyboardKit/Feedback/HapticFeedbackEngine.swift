//
//  HapticFeedbackEngine.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to prepare and trigger haptic feedback.

 该协议可以由任何可用于准备和触发触觉反馈的类来实现。
 */
public protocol HapticFeedbackEngine {
  /**
   Prepare a certain haptic feedback type.

   准备某种触觉反馈类型。
   */
  func prepare(_ feedback: HapticFeedback)

  /**
   Trigger a certain haptic feedback type.

   触发某种触觉反馈类型。
   */
  func trigger(_ feedback: HapticFeedback)
}
