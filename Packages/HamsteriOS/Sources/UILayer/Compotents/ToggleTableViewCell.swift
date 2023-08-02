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

  // MARK: properties

  public var settingItem: SettingItemModel {
    didSet {
      setupToggleView()
    }
  }

  let switchView: UISwitch = {
    let switchView = UISwitch(frame: .zero)
    return switchView
  }()

  // MARK: methods

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.settingItem = SettingItemModel()

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupToggleView()
  }

  func setupToggleView() {
    switchView.setOn(settingItem.toggleValue, animated: false)
    switchView.addTarget(self, action: #selector(toggleAction), for: .valueChanged)
    accessoryView = switchView
  }

  @objc func toggleAction(_ sender: UISwitch) {
    settingItem.toggleValue = sender.isOn
    settingItem.toggleHandled?(sender.isOn)
  }

  override func prepareForReuse() {
    settingItem.text = ""
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    var config = UIListContentConfiguration.cell()
    config.text = settingItem.text
    config.secondaryText = settingItem.secondaryText
    contentConfiguration = config

    setupToggleView()
  }
}
