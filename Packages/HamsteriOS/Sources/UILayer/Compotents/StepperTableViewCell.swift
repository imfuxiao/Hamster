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

  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.settingItemModel = self.settingItem
    return state
  }

  public var settingItem: SettingItemModel? = nil

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
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupStepView()
  }

  func setupStepView() {
    contentView.addSubview(containerView)
    containerView.fillSuperviewOnMarginsGuide()
  }

  @objc func changeValue(_ sender: UIStepper) {
    settingItem?.valueChangeHandled?(sender.value)
    valueLabel.text = String(Int(stepper.value))
  }

  func updateWithSettingItem(_ item: SettingItemModel) {
    // guard settingItem != item else { return }
    self.settingItem = item
    setNeedsUpdateConfiguration()
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    label.text = ""
    valueLabel.text = ""
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    label.text = state.settingItemModel?.text
    if let minValue = state.settingItemModel?.minValue {
      stepper.minimumValue = minValue
    }
    if let maxValue = state.settingItemModel?.maxValue {
      stepper.maximumValue = maxValue
    }
    if let stepValue = state.settingItemModel?.stepValue {
      stepper.stepValue = stepValue
    }

    if let value = state.settingItemModel?.textValue?() {
      valueLabel.text = value
      stepper.value = Double(value) ?? 0
    }
  }
}
