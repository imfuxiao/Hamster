//
//  ToggleTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {
  static let identifier = "ToggleTableViewCell"

  init(text: String, secondaryText: String? = nil, toggleValue: Bool = false, toggleHandled: ((Bool) -> Void)? = nil) {
    self.text = text
    self.secondaryText = secondaryText
    self.toggleValue = toggleValue
    self.toggleHandled = toggleHandled

    super.init(style: .default, reuseIdentifier: Self.identifier)

    let switchView = switchView
    switchView.setOn(toggleValue, animated: false)
    switchView.addTarget(self, action: #selector(toggleAction), for: .valueChanged)
    self.accessoryView = switchView
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var text: String = ""
  var secondaryText: String?
  var toggleValue: Bool = false
  var toggleHandled: ((Bool) -> Void)?

  let switchView: UISwitch = {
    let switchView = UISwitch(frame: .zero)
    return switchView
  }()

  @objc func toggleAction(_ sender: UISwitch) {
    toggleHandled?(sender.isOn)
  }

  override func prepareForReuse() {
    text = ""
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    var config = UIListContentConfiguration.cell()
    config.text = text
    config.secondaryText = secondaryText
    contentConfiguration = config
  }
}
