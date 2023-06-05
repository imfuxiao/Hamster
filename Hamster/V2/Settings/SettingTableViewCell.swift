//
//  SettingCellTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
  static let identifier = "SettingTableViewCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentConfiguration = UIListContentConfiguration.valueCell()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var setting: SettingModel?

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    guard var config = contentConfiguration as? UIListContentConfiguration else { return }
    guard let setting = setting else { return }

    config.text = setting.text
    config.secondaryText = setting.navigationLinkLabel()

    config.image = setting.icon

    if let accessoryType = setting.accessoryType {
      self.accessoryType = accessoryType
    }
    contentConfiguration = config
  }
}
