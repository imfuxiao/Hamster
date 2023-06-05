//
//  SettingModel.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import UIKit

struct SettingSection {
  var title: String
  var items: [SettingModel]
}

struct SettingModel {
  init(
    icon: UIImage,
    iconBackgroundColor: UIColor? = nil,
    text: String,
    secondaryText: String? = nil,
    accessoryType: UITableViewCell.AccessoryType? = nil,
    navigationLinkLabel: @escaping (() -> String) = { "" },
    navigationLink: (() -> UIViewController)? = nil
  ) {
    self.icon = icon
    self.iconBackgroundColor = iconBackgroundColor
    self.text = text
    self.secondText = secondaryText
    self.accessoryType = accessoryType
    self.navigationLinkLabel = navigationLinkLabel
    self.navigationLink = navigationLink
  }

  var icon: UIImage
  var iconBackgroundColor: UIColor?
  var text: String
  var secondText: String?
  var accessoryType: UITableViewCell.AccessoryType?
  let navigationLinkLabel: () -> String
  var navigationLink: (() -> UIViewController)?
}
