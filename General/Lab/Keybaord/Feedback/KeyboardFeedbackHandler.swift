//
//  KeyboardFeedbackHandler.swift
//  HamsterKeyboard
//
//  Created by morse on 16/3/2023.
//

import KeyboardKit

class HamsterKeyboardFeedbackHandler: StandardKeyboardFeedbackHandler {
  var appSettings: HamsterAppSettings

  init(settings: KeyboardFeedbackSettings, appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
    super.init(settings: settings)
  }

  override func triggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    if appSettings.enableKeyboardFeedbackSound {
      triggerAudioFeedback(for: gesture, on: action)
    }

    if appSettings.enableKeyboardFeedbackHaptic {
      var hapticFeedback: HamsterHapticFeedback = .success
      if let hapticIntensity = HapticIntensity(rawValue: appSettings.keyboardFeedbackHapticIntensity) {
        hapticFeedback = hapticIntensity.toHapticFeedback()
      }
      HamsterHapticFeedback.engine.trigger(hapticFeedback)
    }
  }

  override func triggerAudioFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    let custom = audioConfig.actions.first { $0.action == action }
    if let custom = custom { return custom.feedback.trigger() }
    if action == .space && gesture == .longPress { return }
    if action == .backspace { return audioConfig.delete.trigger() }
    if action.isHamsterInputAction { return audioConfig.input.trigger() }
    if action.isSystemAction { return audioConfig.system.trigger() }
  }
}
