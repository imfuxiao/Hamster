//
//  AudioFeedbackEngine.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-10-15.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to trigger audio feedback.

 该协议可以由任何可用于触发音频反馈的类来实现。
 */
public protocol AudioFeedbackEngine {
  /**
   Trigger a certain audio feedback type.

   触发某种音频反馈类型。
   **/
  func trigger(_ audio: AudioFeedback)
}
