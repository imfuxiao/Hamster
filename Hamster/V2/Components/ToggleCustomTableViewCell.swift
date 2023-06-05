//
//  ToggleCustomTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import UIKit

class ToggleCustomTableViewCell: UITableViewCell {
  static let identifier = "ToggleCustomTableViewCell"

  init(text: String, tableView: UITableView, customView: UIView, toggleValue: Bool, toggleHandled: @escaping (Bool) -> Void) {
    self.customView = customView
    self.tableView = tableView
    self.toggleHandled = toggleHandled
    super.init(style: .default, reuseIdentifier: Self.identifier)

    label.text = text
    switchView.isOn = toggleValue

    if switchView.isOn {
      secondaryView.addArrangedSubview(customView)
    }

    contentView.addSubview(firstView)
    contentView.addSubview(secondaryView)
    NSLayoutConstraint.activate([
      firstView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      firstView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      firstView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

      secondaryView.topAnchor.constraint(equalToSystemSpacingBelow: firstView.bottomAnchor, multiplier: 1.0),
      secondaryView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      secondaryView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      secondaryView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  unowned var tableView: UITableView?
  var customView: UIView
  var toggleHandled: (Bool) -> Void

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
//    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
//    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return label
  }()

  lazy var switchView: UISwitch = {
    let switchView = UISwitch(frame: .zero)
    switchView.addTarget(self, action: #selector(toggleAction), for: .valueChanged)
    return switchView
  }()

  private lazy var firstView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    stackView.addArrangedSubview(label)
    stackView.addArrangedSubview(switchView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  private lazy var secondaryView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
}

// MARK: custom method

extension ToggleCustomTableViewCell {
  @objc func toggleAction(_ sender: UISwitch) {
    toggleHandled(sender.isOn)
    if sender.isOn {
      secondaryView.addArrangedSubview(customView)
//      NSLayoutConstraint.activate([
//        customView.leadingAnchor.constraint(equalTo: secondaryView.leadingAnchor),
//        customView.trailingAnchor.constraint(equalTo: secondaryView.trailingAnchor),
//      ])
    } else {
      customView.removeFromSuperview()
      secondaryView.removeArrangedSubview(customView)
    }
    tableView?.reloadData()
  }
}
