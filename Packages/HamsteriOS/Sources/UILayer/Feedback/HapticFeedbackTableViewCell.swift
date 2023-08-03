//
//  ToggleCustomTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import Combine
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
    secondaryRowView.topAnchor.constraint(equalToSystemSpacingBelow: firstRowView.bottomAnchor, multiplier: 1.0),
    secondaryRowView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
    secondaryRowView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
    secondaryRowView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
  ]

  private var activityConstraints: [NSLayoutConstraint] = []

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "按键震动"
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

    return stackView
  }()

  /// 反馈强度滑动
  private lazy var hapticFeedbackIntensitySlideView: UISlider = {
    let slider = UISlider(frame: .zero)
    slider.minimumValue = Float(keyboardFeedbackViewModel.minimumHapticFeedbackIntensity)
    slider.maximumValue = Float(keyboardFeedbackViewModel.maximumHapticFeedbackIntensity)
    slider.isContinuous = false
    slider.value = Float(keyboardFeedbackViewModel.hapticFeedbackIntensity)
    slider.addTarget(
      keyboardFeedbackViewModel,
      action: #selector(keyboardFeedbackViewModel.changeHaptic(_:)),
      for: .valueChanged
    )
    return slider
  }()

  private lazy var secondaryRowView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    let leftImage = image(name: "iphone.radiowaves.left.and.right")
    leftImage.tintColor = .secondaryLabel

    stackView.addArrangedSubview(leftImage)
    stackView.addArrangedSubview(hapticFeedbackIntensitySlideView)
    stackView.addArrangedSubview(image(name: "iphone.radiowaves.left.and.right"))

    return stackView
  }()

  // MARK: methods

  init(keyboardFeedbackViewModel: KeyboardFeedbackViewModel) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModel

    super.init(style: .default, reuseIdentifier: Self.identifier)

    setupView()
  }

  func setupView() {
    if !keyboardFeedbackViewModel.enableHapticFeedback {
      activityConstraints = staticConstraints + dynamicFirstRowConstraints
      contentView.addSubview(firstRowView)
      firstRowView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate(activityConstraints)
      return
    }

    activityConstraints = staticConstraints + dynamicSecondaryRowConstraints
    contentView.addSubview(firstRowView)
    contentView.addSubview(secondaryRowView)
    firstRowView.translatesAutoresizingMaskIntoConstraints = false
    secondaryRowView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(activityConstraints)
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    if !activityConstraints.isEmpty {
      NSLayoutConstraint.deactivate(activityConstraints)
      activityConstraints.removeAll()
    }
    setupView()
  }

  private func image(name: String) -> UIImageView {
    let view = UIImageView(image: UIImage(systemName: name))
    view.contentMode = .scaleAspectFit
    return view
  }
}
