//
//  AboutTableViewCell.swift
//
//
//  Created by morse on 2023/7/7.
//

import HamsterUIKit
import UIKit

class AboutTableViewCell: NibLessTableViewCell {
  static let identifier = "AboutTableViewCell"

  var aboutInfo: AboutCellInfo

  init(aboutInfo: AboutCellInfo) {
    self.aboutInfo = aboutInfo

    super.init(style: .default, reuseIdentifier: Self.identifier)

    if let type = aboutInfo.accessoryType {
      accessoryType = type
    }
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.aboutInfo = .init(text: "")
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    var config = UIListContentConfiguration.valueCell()
    config.text = aboutInfo.text
    config.secondaryText = aboutInfo.secondaryText
    contentConfiguration = config

    if let type = aboutInfo.accessoryType {
      accessoryType = type
    }
  }
}
