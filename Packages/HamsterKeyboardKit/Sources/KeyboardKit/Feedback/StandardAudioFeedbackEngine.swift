//
//  StandardAudioFeedbackEngine.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-10-15.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import AudioToolbox

/**
 This engine uses system features to trigger audio feedbacks.
 It is the default ``AudioFeedback/engine`` on all platforms
 where it's supported.

 该引擎使用系统功能触发音频反馈。
 在所有支持该引擎的平台上，它都是默认的 ``AudioFeedback/engine`` 引擎。

 You can use, modify and replace the ``shared`` engine. This
 lets you customize the global audio feedback experience.

 您可以使用、修改和替换 "shared" 引擎。这可以让你定制全局音频反馈。

 Note that the engine is currently only supported on certain
 platforms.

 请注意，该引擎目前仅支持某些平台。
 */
open class StandardAudioFeedbackEngine: AudioFeedbackEngine {
  public init() {}

  /**
   Trigger a certain audio feedback type.

   触发某种音频反馈类型。
   **/
  open func trigger(_ audio: AudioFeedback) {
    switch audio {
    case .none: return
    default:
      DispatchQueue.global().async {
        AudioServicesPlaySystemSound(audio.id)
      }
    }
  }
}

public extension StandardAudioFeedbackEngine {
  /**
   A shared instance that can be used from anywhere.

   可在任何地方使用的共享实例。
   */
  static var shared = StandardAudioFeedbackEngine()
}
