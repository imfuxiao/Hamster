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
    contentConfiguration = UIListContentConfiguration.subtitleCell()
  }

  var openSourceInfo: OpenSourceInfo

  override func updateConfiguration(using state: UICellConfigurationState) {
    guard var config = contentConfiguration as? UIListContentConfiguration else { return }
    config.text = openSourceInfo.name
    config.secondaryText = openSourceInfo.projectURL
    contentConfiguration = config
  }
}
