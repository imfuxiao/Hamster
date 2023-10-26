//
//  ToggleTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import HamsterUIKit
import UIKit

class ToggleTableViewCell: NibLessTableViewCell {
  static let identifier = "ToggleTableViewCell"

  // MARK: - properties

  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.settingItemModel = self.settingItem
    return state
  }

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var switchView: UISwitch = {
    let switchView = UISwitch(frame: .zero)
    switchView.addTarget(self, action: #selector(toggleAction), for: .valueChanged)
    switchView.translatesAutoresizingMaskIntoConstraints = false
    return switchView
  }()

  public var settingItem: SettingItemModel? = nil

  // MARK: - initialization

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
//    accessoryView = switchView

    contentView.addSubview(label)
    contentView.addSubview(switchView)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1),
      label.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),

      switchView.leadingAnchor.constraint(equalTo: label.trailingAnchor),
      switchView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: switchView.trailingAnchor, multiplier: 1)
    ])
  }

  // MARK: - methods

  override func prepareForReuse() {
    super.prepareForReuse()
    label.text = ""
  }

  func updateWithSettingItem(_ item: SettingItemModel) {
    // guard settingItem != item else { return }
    self.settingItem = item
    setNeedsUpdateConfiguration()
  }

  @objc func toggleAction(_ sender: UISwitch) {
    settingItem?.toggleHandled?(sender.isOn)
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    guard state.settingItemModel != nil else { return }

    label.text = state.settingItemModel?.text
    if let toggleValue = state.settingItemModel?.toggleValue {
      let value = toggleValue()
      switchView.setOn(value, animated: false)
    }

//    var config = UIListContentConfiguration.cell()
//    config.text = state.settingItemModel?.text
//    config.secondaryText = state.settingItemModel?.secondaryText
//    if let toggleValue = state.settingItemModel?.toggleValue {
//      switchView.setOn(toggleValue(), animated: false)
//    }
//    contentConfiguration = config
  }
}
