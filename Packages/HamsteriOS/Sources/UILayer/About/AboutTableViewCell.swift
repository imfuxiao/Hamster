//
//  AboutTableViewCell.swift
//
//
//  Created by morse on 2023/7/7.
//

import UIKit

class AboutTableViewCell: UITableViewCell {
  static let identifier = "AboutTableViewCell"

  init(aboutInfo: AboutCellInfo) {
    self.aboutInfo = aboutInfo

    super.init(style: .default, reuseIdentifier: Self.identifier)
    var config = UIListContentConfiguration.valueCell()
    config.text = aboutInfo.text
    config.secondaryText = aboutInfo.secondaryText
    contentConfiguration = config
    if let type = aboutInfo.accessoryType {
      accessoryType = type
    }
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.aboutInfo = .init(text: "")
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentConfiguration = UIListContentConfiguration.valueCell()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var aboutInfo: AboutCellInfo

  override func updateConfiguration(using state: UICellConfigurationState) {
    if var config = contentConfiguration as? UIListContentConfiguration {
      config.text = aboutInfo.text
      config.secondaryText = aboutInfo.secondaryText
      contentConfiguration = config
    }
    if let type = aboutInfo.accessoryType {
      accessoryType = type
    }
  }
}
