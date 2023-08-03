//
//  OpenSourceTableViewCell.swift
//
//
//  Created by morse on 2023/7/7.
//
import HamsterUIKit
import UIKit

class OpenSourceTableViewCell: NibLessTableViewCell {
  static let identifier = "OpenSourceTableViewCell"

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.openSourceInfo = .init(name: "", projectURL: "")
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  var openSourceInfo: OpenSourceInfo

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    var config = UIListContentConfiguration.subtitleCell()
    config.text = openSourceInfo.name
    config.secondaryText = openSourceInfo.projectURL
    contentConfiguration = config
  }
}
