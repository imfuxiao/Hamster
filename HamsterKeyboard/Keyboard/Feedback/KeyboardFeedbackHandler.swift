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
      var hapticFeedfack: HapticFeedback = .mediumImpact
      if let hapticIntensity = HapticIntensity(rawValue: appSettings.keyboardFeedbackHapticIntensity) {
        switch hapticIntensity {
        case .ultraLightImpact:
          hapticFeedfack = .selectionChanged
        case .lightImpact:
          hapticFeedfack = .lightImpact
        case .mediumImpact:
          hapticFeedfack = .mediumImpact
        case .heavyImpact:
          hapticFeedfack = .heavyImpact
        }
      }
      HapticFeedback.engine.trigger(hapticFeedfack)
    }
  }
}
