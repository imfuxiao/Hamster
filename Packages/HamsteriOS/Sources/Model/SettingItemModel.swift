//
//  SettingItemModel.swift
//
//
//  Created by morse on 2023/7/5.
//

import Foundation
import UIKit

public struct SettingItemModel: Hashable, Identifiable {
  public var id = UUID()
  public var icon: UIImage?
  public var iconBackgroundColor: UIColor?
  public var text: String
  public var placeholder: String
  public var textTintColor: UIColor?
  public var secondaryText: String?
  public var accessoryType: UITableViewCell.AccessoryType
  public var type: SettingType
  public var toggleValue: Bool
  public var toggleHandled: ((Bool) -> Void)?
  public var navigationAction: (() -> Void)?
  public var navigationLinkLabel: () -> String
  public var textValue: String?
  public var textHandled: ((String) -> Void)?
  public var shouldBeginEditing: ((UITextField) -> Bool)?
  public var buttonAction: (() throws -> Void)?
  public var favoriteButton: FavoriteButton?
  public var favoriteButtonHandler: (() -> Void)?

  init(
    icon: UIImage? = nil,
    iconBackgroundColor: UIColor? = nil,
    text: String = "",
    textTintColor: UIColor? = nil,
    secondaryText: String? = nil,
    accessoryType: UITableViewCell.AccessoryType = .none,
    placeholder: String = "",
    type: SettingType = .navigation,
    toggleValue: Bool = false,
    toggleHandled: ((Bool) -> Void)? = nil,
    navigationLinkLabel: @escaping (() -> String) = { "" },
    navigationAction: (() -> Void)? = nil,
    textValue: String? = nil,
    textHandled: ((String) -> Void)? = nil,
    shouldBeginEditing: ((UITextField) -> Bool)? = nil,
    buttonAction: (() throws -> Void)? = nil,
    favoriteButton: FavoriteButton? = nil,
    favoriteButtonHandler: (() -> Void)? = nil
  ) {
    self.icon = icon
    self.iconBackgroundColor = iconBackgroundColor
    self.text = text
    self.placeholder = placeholder
    self.textTintColor = textTintColor
    self.secondaryText = secondaryText
    self.accessoryType = accessoryType
    self.type = type
    self.favoriteButton = favoriteButton
    self.toggleValue = toggleValue
    self.toggleHandled = toggleHandled
    self.navigationLinkLabel = navigationLinkLabel
    self.navigationAction = navigationAction
    self.textValue = textValue
    self.textHandled = textHandled
    self.shouldBeginEditing = shouldBeginEditing
    self.buttonAction = buttonAction
    self.favoriteButton = favoriteButton
    self.favoriteButtonHandler = favoriteButtonHandler
  }
}

public extension SettingItemModel {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: SettingItemModel, rhs: SettingItemModel) -> Bool {
    lhs.id == rhs.id
  }
}
