//
//  KeyboardFeedbackViewModel.swift
//
//
//  Created by morse on 14/7/2023.
//

import HamsterModel
import UIKit

public class KeyboardFeedbackViewModel {
  // MARK: properties

  public var enableKeySounds: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableKeySounds = enableKeySounds
    }
  }

  @Published
  public var enableHapticFeedback: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableHapticFeedback = enableHapticFeedback
    }
  }

  public var hapticFeedbackIntensity: Int {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.hapticFeedbackIntensity = hapticFeedbackIntensity
    }
  }

  public let minimumHapticFeedbackIntensity: Int = 0

  public let maximumHapticFeedbackIntensity: Int = 4

  // MARK: methods

  init(configuration: HamsterConfiguration) {
    self.enableKeySounds = configuration.Keyboard?.enableKeySounds ?? true
    self.enableHapticFeedback = configuration.Keyboard?.enableHapticFeedback ?? false
    self.hapticFeedbackIntensity = configuration.Keyboard?.hapticFeedbackIntensity ?? 2
  }

  @objc func changeHaptic(_ sender: UISlider) {
    // 取整
    // TODO:
//    sender.value.round()
//    let senderValue = Int(sender.value)
//    Logger.shared.log.debug("change haptic: \(senderValue)")
//    let haptic = HapticIntensity(rawValue: senderValue) ?? .rigidImpact
//    haptic.toHapticFeedback().trigger()
//    appSettings.keyboardFeedbackHapticIntensity = haptic.rawValue
  }

  @objc func toggleAction(_ sender: UISwitch) {
    enableHapticFeedback = sender.isOn
  }
}
