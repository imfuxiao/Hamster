//
//  StepperTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import HamsterUIKit
import UIKit

class StepperView: NibLessView {
  // MARK: properties

  private let stepperModel: StepperModel

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return label
  }()

  lazy var valueLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.tintColor = UIColor.secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var stepper: UIStepper = {
    let stepper = UIStepper()
    stepper.addTarget(
      self,
      action: #selector(changeValue(_:)),
      for: .valueChanged
    )
    return stepper
  }()

  private lazy var containerView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    return stackView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, stepperModel: StepperModel) {
    self.stepperModel = stepperModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    containerView.addArrangedSubview(label)
    containerView.addArrangedSubview(valueLabel)
    containerView.addArrangedSubview(stepper)
  }

  override func activateViewConstraints() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
    ])
  }

  @objc func changeValue(_ sender: UIStepper) {
    stepperModel.valueChangeHandled(sender.value)
    valueLabel.text = String(Int(stepper.value))
  }
}

class StepperTableViewCell: NibLessTableViewCell {
  static let identifier = "StepperTableViewCell"

  public var stepperModel: StepperModel

  init(stepperModel: StepperModel) {
    self.stepperModel = stepperModel

    super.init(style: .default, reuseIdentifier: Self.identifier)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.stepperModel = StepperModel()
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    contentView.subviews.forEach { $0.removeFromSuperview() }
    let view = StepperView(stepperModel: stepperModel)
    contentView.addSubview(view)
  }
}
