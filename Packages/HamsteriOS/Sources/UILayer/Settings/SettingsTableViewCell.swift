//
//  SettingCellTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import HamsterUIKit
import UIKit

public class SettingTableViewCell: NibLessTableViewCell {
  static let identifier = "SettingTableViewCell"

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentConfiguration = UIListContentConfiguration.valueCell()
  }

  var setting: SettingItemModel?

  override public func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    guard var config = contentConfiguration as? UIListContentConfiguration else { return }
    guard let setting = setting else { return }

    config.text = setting.text
    config.secondaryText = setting.navigationLinkLabel()
    config.image = setting.icon
    accessoryType = setting.accessoryType
    contentConfiguration = config
  }
}
