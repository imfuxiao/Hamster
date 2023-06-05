//
//  StepperTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import UIKit

class StepperTableViewCell: UITableViewCell {
  static let identifier = "StepperTableViewCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(containerView)
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var valueChangeHandled: ((Double) -> Void)?

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
    stepper.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
    stepper.translatesAutoresizingMaskIntoConstraints = false
    return stepper
  }()

  private lazy var containerView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    stackView.addArrangedSubview(label)
    stackView.addArrangedSubview(valueLabel)
    stackView.addArrangedSubview(stepper)
    stackView.translatesAutoresizingMaskIntoConstraints = false

    return stackView
  }()

  @objc func changeValue(_ sender: UIStepper) {
    valueChangeHandled?(sender.value)
    valueLabel.text = String(Int(stepper.value))
  }
}
