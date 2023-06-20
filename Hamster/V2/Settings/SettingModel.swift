//
//  SettingModel.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import UIKit

enum SettingType {
  case navigation
  case toggle
  case textField
  case button
}

struct SettingSectionModel {
  init(title: String = "", footer: String? = nil, items: [SettingItemModel]) {
    self.title = title
    self.footer = footer
    self.items = items
  }

  let title: String
  let footer: String?
  let items: [SettingItemModel]
}

struct SettingItemModel {
  init(
    icon: UIImage? = nil,
    iconBackgroundColor: UIColor? = nil,
    text: String = "",
    textTintColor: UIColor? = nil,
    secondaryText: String? = nil,
    accessoryType: UITableViewCell.AccessoryType = .none,
    type: SettingType = .navigation,
    favoriteButton: FavoriteButton? = nil,
    toggleValue: Bool = false,
    toggleHandled: ((Bool) -> Void)? = nil,
    navigationLinkLabel: @escaping (() -> String) = { "" },
    navigationLink: (() -> UIViewController)? = nil,
    textValue: String? = nil,
    textHandled: ((String) -> Void)? = nil,
    buttonAction: (() -> Void)? = nil
  ) {
    self.icon = icon
    self.iconBackgroundColor = iconBackgroundColor
    self.text = text
    self.textTintColor = textTintColor
    self.secondaryText = secondaryText
    self.accessoryType = accessoryType
    self.type = type
    self.favoriteButton = favoriteButton
    self.toggleValue = toggleValue
    self.toggleHandled = toggleHandled
    self.navigationLinkLabel = navigationLinkLabel
    self.navigationLink = navigationLink
    self.textValue = textValue
    self.textHandled = textHandled
    self.buttonAction = buttonAction
  }

  let icon: UIImage?
  let iconBackgroundColor: UIColor?
  let text: String
  let textTintColor: UIColor?
  let secondaryText: String?
  let accessoryType: UITableViewCell.AccessoryType
  let type: SettingType
  let favoriteButton: FavoriteButton?
  let toggleValue: Bool
  let toggleHandled: ((Bool) -> Void)?
  let navigationLink: (() -> UIViewController)?
  let navigationLinkLabel: () -> String
  let textValue: String?
  let textHandled: ((String) -> Void)?
  let buttonAction: (() -> Void)?
}
