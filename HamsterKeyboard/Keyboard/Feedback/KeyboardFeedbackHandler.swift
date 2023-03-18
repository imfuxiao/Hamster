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
      HapticFeedback.engine.trigger(.heavyImpact)
    }
  }
}
