//
//  KeyboardFeedbackSettings.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Combine
import Foundation

/**
 This class can be used to specify what kind of feedback the
 current keyboard should give to the user.

 该类可用于指定当前键盘应向用户提供何种反馈。

 KeyboardKit will create an observable setting instance when
 the keyboard extension is started, then apply this instance
 to ``KeyboardInputViewController/keyboardFeedbackSettings``.
 It will then use this instance by default to determine what
 feedback that should be given for a certain action.

 KeyboardKit 会在启动键盘扩展时创建一个可观察的设置实例，
 然后将该实例应用到 ``KeyboardInputViewController/keyboardFeedbackSettings`` 中。
 默认情况下，它将使用该实例来确定特定操作应获得的反馈。

 This instance is used by ``StandardKeyboardFeedbackHandler``,
 which means that you can change the basic feedback behavior
 without having to create a custom feedback handler. However,
 more complex changes require a custom feedback handler.

 该实例由 ``StandardKeyboardFeedbackHandler`` 使用，这意味着无需创建自定义反馈处理程序即可修改反馈行为。
 不过，更复杂的逻辑则需要自定义实现反馈处理程序。
 */
public class KeyboardFeedbackSettings: ObservableObject {
  /**
   The configuration to use for audio feedback.

   用于音频反馈的配置。
   */
  @Published
  public var audioConfiguration: AudioFeedbackConfiguration

  /**
   The configuration to use for haptic feedback.

   用于触觉反馈的配置。
   */
  @Published
  public var hapticConfiguration: HapticFeedbackConfiguration

  /**
   Create a settings instance.

   - Parameters:
     - audioConfiguration: The configuration to use for audio feedback.
     - hapticConfiguration: The configuration to use for haptic feedback.
   */
  public init(
    audioConfiguration: AudioFeedbackConfiguration = .standard,
    hapticConfiguration: HapticFeedbackConfiguration = .standard
  ) {
    self.audioConfiguration = audioConfiguration
    self.hapticConfiguration = hapticConfiguration
  }
}

public extension KeyboardFeedbackSettings {
  /**
    This specifies a standard feedback configuration.

   这指定了标准反馈配置。
   */
  static let standard = KeyboardFeedbackSettings()
}

public extension KeyboardFeedbackSettings {
  /**
   Whether or not the ``audioConfiguration`` is enabled.

   ``audioConfiguration`` 是否启用。

   The configuration is enabled if it has any other config
   than ``AudioFeedbackConfiguration/noFeedback``.

   如果配置中除了 ``AudioFeedbackConfiguration/noFeedback`` 以外还有其他配置，则该配置将被启用。
   */
  var isAudioFeedbackEnabled: Bool {
    audioConfiguration != .noFeedback
  }

  /**
   Whether or not the ``hapticConfiguration`` is enabled.

   ``hapticConfiguration`` 是否启用。

   The configuration is enabled if it has any other config
   than ``HapticFeedbackConfiguration/noFeedback``.

   如果该配置具有除 ``HapticFeedbackConfiguration/noFeedback`` 以外的任何其他配置，则会启用。
   */
  var isHapticFeedbackEnabled: Bool {
    hapticConfiguration != .noFeedback
  }

  /**
   Disable audio feedback.

   禁用音频反馈。

   This applies ``AudioFeedbackConfiguration/noFeedback``.

   这适用于 ``AudioFeedbackConfiguration/noFeedback``。
   */
  func disableAudioFeedback() {
    audioConfiguration = .noFeedback
  }

  /**
   Disable haptic feedback.

   禁用触觉反馈。

   This applies ``HapticFeedbackConfiguration/noFeedback``.

   这适用于 ``HapticFeedbackConfiguration/noFeedback``。
   */
  func disableHapticFeedback() {
    hapticConfiguration = .noFeedback
  }

  /**
   Enable audio feedback.

   启用音频反馈。

   This applies ``AudioFeedbackConfiguration/standard``.

   这适用于 ``AudioFeedbackConfiguration/standard``。
   */
  func enableAudioFeedback() {
    audioConfiguration = .standard
  }

  /**
   Enable haptic feedback.

   启用触觉反馈。

   This applies ``HapticFeedbackConfiguration/standard``.

   这适用于 ``HapticFeedbackConfiguration/standard``。
   */
  func enableHapticFeedback() {
    hapticConfiguration = .standard
  }

  /**
   Toggle audio feedback between enabled and disabled.

   在启用和禁用之间切换音频反馈。
   */
  func toggleAudioFeedback() {
    if isAudioFeedbackEnabled {
      disableAudioFeedback()
    } else {
      enableAudioFeedback()
    }
  }

  /**
   Toggle haptic feedback between enabled and disabled.

   在启用和禁用之间切换触觉反馈。
   */
  func toggleHapticFeedback() {
    if isHapticFeedbackEnabled {
      disableHapticFeedback()
    } else {
      enableHapticFeedback()
    }
  }
}
