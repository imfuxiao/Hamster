//
//  KeyboardFeedbackViewModel.swift
//
//
//  Created by morse on 14/7/2023.
//

import Combine
import HamsterKit
import HamsterModel
import HamsterUIKit
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

  public let hapticFeedbackStateSubject = PassthroughSubject<Bool, Never>()
  public var hapticFeedbackStatePublished: AnyPublisher<Bool, Never> {
    hapticFeedbackStateSubject.eraseToAnyPublisher()
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

  @objc func changeHaptic(_ control: UIControl) {
    if let control = control as? StepSlider {
      logger.debug("change haptic: \(control.index)")
      hapticFeedbackIntensity = Int(control.index)
    }
  }

  @objc func toggleAction(_ sender: UISwitch) {
    enableHapticFeedback = sender.isOn
  }
}
