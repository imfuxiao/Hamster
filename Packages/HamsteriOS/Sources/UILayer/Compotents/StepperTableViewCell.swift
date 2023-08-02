//
//  StepperTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import HamsterUIKit
import UIKit

class StepperTableViewCell: NibLessTableViewCell {
  static let identifier = "StepperTableViewCell"

  // MARK: properties

  public var stepperModel: StepperModel {
    didSet {
      label.text = stepperModel.text
      valueLabel.text = String(Int(stepperModel.value))
      stepper.minimumValue = stepperModel.minValue
      stepper.maximumValue = stepperModel.maxValue
      stepper.stepValue = stepperModel.stepValue
      stepper.value = stepperModel.value
    }
  }

  let label: UILabel = {
    let label = UILabel(frame: .zero)
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return label
  }()

  let valueLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.tintColor = UIColor.secondaryLabel
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

  lazy var containerView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [label, valueLabel, stepper])

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    return stackView
  }()

  // MARK: methods

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.stepperModel = StepperModel()

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupStepView()
  }

  func setupStepView() {
    contentView.addSubview(containerView)
    containerView.fillSuperviewOnMarginsGuide()
  }

  @objc func changeValue(_ sender: UIStepper) {
    stepperModel.valueChangeHandled(sender.value)
    valueLabel.text = String(Int(stepper.value))
  }
}
