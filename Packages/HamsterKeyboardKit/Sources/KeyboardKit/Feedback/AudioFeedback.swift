//
//  AudioFeedback.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-10-15.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum contains various audio feedback types.
 
 该枚举包含各种音频反馈类型。
  
 You can call ``trigger()`` on any feedback value to trigger
 it, using the static ``engine``. You can replace the engine
 with any custom engine if you need to.
 
 您可以使用 static 的 ``engine`` 对任何反馈值调用 ``trigger()`` 来触发它。
 如果需要，您可以使用任何自定义 engine 来替换该 engine。

 Note that `watchOS` creates a ``DisabledAudioFeedbackEngine``
 by default, since the platform doesn't support system audio.
 You can replace it with another engine, that does something
 meaningful on that platform.
 
 请注意，`watchOS` 默认创建了一个``DisabledAudioFeedbackEngine``，
 因为该平台不支持系统音频。你可以用其他 engine 来替代它，在该平台上做一些有意义的事情。
 */
public enum AudioFeedback: Codable, Equatable, Identifiable {
  /// Represents the sound of an input key.
  ///
  ///  代表输入按键的声音。
  case input
    
  /// Represents the sound of a system key.
  ///
  /// 代表系统按键的声音。
  case system
    
  /// Represents the sound of a delete key.
  ///
  /// 代表删除键的声音。
  case delete
    
  /// Represents a custom system sound.
  ///
  /// 代表自定义系统声音。
  case custom(id: UInt32)
    
  /// Can be used to disable feedback.
  ///
  /// 可用于禁用音频反馈。
  case none
}

public extension AudioFeedback {
  /**
   The unique feedback identifier.
   
   AudioFeedback 唯一的标识符。

   This identifier maps to a unique system sound, which is
   used by the ``StandardAudioFeedbackEngine``.
   
   该标识符映射到一个唯一的系统声音，
   该声音由 ``StandardAudioFeedbackEngine`` 使用。
   */
  var id: UInt32 {
    switch self {
    case .input: return 1104
    case .delete: return 1155
    case .system: return 1156
    case .custom(let value): return value
    case .none: return 0
    }
  }

  /**
   The engine that will be used to trigger audio feedback.
   
   用于触发音频反馈的引擎。
   */
  static var engine: AudioFeedbackEngine = StandardAudioFeedbackEngine.shared
    
  /**
   Trigger the feedback, using the shared feedback engine.
   
   使用共享反馈引擎触发反馈。
   */
  func trigger() {
    Self.engine.trigger(self)
  }
}
