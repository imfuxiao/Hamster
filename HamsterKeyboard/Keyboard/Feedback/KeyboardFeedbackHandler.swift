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
      print("\n \n feedback sound \n\n")
      triggerAudioFeedback(for: gesture, on: action)
    }

    if appSettings.enableKeyboardFeedbackHaptic {
      print("\n \n feedback haptic \n\n")
      triggerHapticFeedback(for: gesture, on: action)
      
      HapticFeedback.engine.trigger(.heavyImpact)
    }
  }
}
