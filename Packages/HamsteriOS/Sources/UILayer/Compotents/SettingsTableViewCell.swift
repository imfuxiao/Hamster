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

  private var setting: SettingItemModel?

  override public var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.settingItemModel = self.setting
    return state
  }

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  func updateWithSettingItem(_ item: SettingItemModel) {
    guard setting != item else { return }
    self.setting = item
    setNeedsUpdateConfiguration()
  }

  override public func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    var config = UIListContentConfiguration.valueCell()
    config.text = state.settingItemModel?.text
    config.textProperties.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    if state.settingItemModel?.type == .navigation {
      config.secondaryText = state.settingItemModel?.navigationLinkLabel()
    } else {
      config.secondaryText = state.settingItemModel?.secondaryText
    }
    config.secondaryTextProperties.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    config.image = state.settingItemModel?.icon
    if let type = state.settingItemModel?.accessoryType {
      accessoryType = type
    }
    contentConfiguration = config
  }
}
