//
//  ToggleCustomTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import Combine
import HamsterKeyboardKit
import HamsterUIKit
import UIKit

class HapticFeedbackTableViewCell: NibLessTableViewCell {
  static let identifier = "HapticFeedbackTableViewCell"

  // MARK: properties

  private var subscriptions = Set<AnyCancellable>()

  private let keyboardFeedbackViewModel: KeyboardFeedbackViewModel

  private lazy var staticConstraints: [NSLayoutConstraint] = [
    firstRowView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
    firstRowView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
    firstRowView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
  ]

  private lazy var dynamicFirstRowConstraints: [NSLayoutConstraint] = [
    firstRowView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
  ]

  private lazy var dynamicSecondaryRowConstraints: [NSLayoutConstraint] = [
    secondaryRowView.topAnchor.constraint(equalToSystemSpacingBelow: firstRowView.bottomAnchor, multiplier: 1.5),
    secondaryRowView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
    secondaryRowView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
    secondaryRowView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
  ]

  private var activityConstraints: [NSLayoutConstraint] = []

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = L10n.Feedback.haptic
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return label
  }()

  lazy var switchView: UISwitch = {
    let switchView = UISwitch(frame: .zero)
    switchView.isOn = keyboardFeedbackViewModel.enableHapticFeedback
    switchView.addTarget(
      keyboardFeedbackViewModel,
      action: #selector(keyboardFeedbackViewModel.toggleAction),
      for: .valueChanged
    )
    return switchView
  }()

  private lazy var firstRowView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [label, switchView])
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  private lazy var secondaryRowView: StepSlider = {
    let slider = StepSlider(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 61))
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.tintColor = .systemGreen
    slider.maxCount = UInt(HapticIntensity.allCases.count)
    slider.index = UInt(keyboardFeedbackViewModel.hapticFeedbackIntensity)
    slider.trackHeight = 1
    slider.trackCircleRadius = 5
    slider.dotsInteractionEnable = true
    slider.sliderCircleRadius = 12.5
    // slider.sliderCircleImage = UIImage(systemName: "")
    slider.trackColor = .systemFill
    slider.labelColor = .label
    slider.sliderCircleColor = .secondarySystemFill
    slider.labelOffset = 20
    slider.adjustLabel = true
    slider.enableHapticFeedback = true
    slider.labels = HapticIntensity.allCases.map { $0.text }
    slider.feedbackGeneratorBuild = {
      // UIImpactFeedbackGenerator(style: HapticIntensity(rawValue: $0)!.feedbackStyle())
      if let intensity = HapticIntensity(rawValue: $0) {
        StandardHapticFeedbackEngine.shared.trigger(intensity.hapticFeedback())
      }
    }

    slider.addTarget(keyboardFeedbackViewModel, action: #selector(keyboardFeedbackViewModel.changeHaptic(_:)), for: .valueChanged)

    return slider
  }()

  // MARK: methods

  init(keyboardFeedbackViewModel: KeyboardFeedbackViewModel) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModel

    super.init(style: .default, reuseIdentifier: Self.identifier)

    setupView()
  }

  func setupView() {
    if !keyboardFeedbackViewModel.enableHapticFeedback {
      contentView.addSubview(firstRowView)
      return
    }
    contentView.addSubview(firstRowView)
    contentView.addSubview(secondaryRowView)

    updateActivityConstraints()
  }

  func updateActivityConstraints() {
    if !keyboardFeedbackViewModel.enableHapticFeedback {
      activityConstraints = staticConstraints + dynamicFirstRowConstraints
      NSLayoutConstraint.activate(activityConstraints)
      return
    }

    activityConstraints = staticConstraints + dynamicSecondaryRowConstraints
    NSLayoutConstraint.activate(activityConstraints)
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    if !activityConstraints.isEmpty {
      NSLayoutConstraint.deactivate(activityConstraints)
      activityConstraints.removeAll()
    }
    updateActivityConstraints()
  }

  private func image(name: String) -> UIImageView {
    let view = UIImageView(image: UIImage(systemName: name))
    view.contentMode = .scaleAspectFit
    return view
  }
}
