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
  public var toggleValue: (() -> Bool)?
  public var toggleHandled: ((Bool) -> Void)?
  public var navigationAction: (() -> Void)?
  public var navigationLinkLabel: () -> String
  public var textValue: (() -> String)?
  public var textFieldShouldBeginEditing: Bool
  public var textHandled: ((String) -> Void)?
  public var shouldBeginEditing: ((UITextField) -> Bool)?
  public var buttonAction: (() async throws -> Void)?
  public var favoriteButton: FavoriteButton?
  public var favoriteButtonHandler: (() -> Void)?
  public var pullDownMenuActionsBuilder: (() -> [UIAction])?

  // step属性
  // step 当前 value 显示，请使用 textValue 设置
  public var minValue: Double
  public var maxValue: Double
  public var stepValue: Double
  public var valueChangeHandled: ((Double) -> Void)?

  init(
    icon: UIImage? = nil,
    iconBackgroundColor: UIColor? = nil,
    text: String = "",
    textTintColor: UIColor? = nil,
    secondaryText: String? = nil,
    accessoryType: UITableViewCell.AccessoryType = .none,
    placeholder: String = "",
    type: SettingType = .navigation,
    toggleValue: (() -> Bool)? = nil,
    toggleHandled: ((Bool) -> Void)? = nil,
    navigationLinkLabel: @escaping (() -> String) = { "" },
    navigationAction: (() -> Void)? = nil,
    textValue: (() -> String)? = nil,
    textFieldShouldBeginEditing: Bool = true,
    textHandled: ((String) -> Void)? = nil,
    shouldBeginEditing: ((UITextField) -> Bool)? = nil,
    buttonAction: (() async throws -> Void)? = nil,
    favoriteButton: FavoriteButton? = nil,
    favoriteButtonHandler: (() -> Void)? = nil,
    pullDownMenuActionsBuilder: (() -> [UIAction])? = nil,
    minValue: Double = 0,
    maxValue: Double = 0,
    stepValue: Double = 1,
    valueChangeHandled: ((Double) -> Void)? = nil
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
    self.textFieldShouldBeginEditing = textFieldShouldBeginEditing
    self.textHandled = textHandled
    self.shouldBeginEditing = shouldBeginEditing
    self.buttonAction = buttonAction
    self.favoriteButton = favoriteButton
    self.favoriteButtonHandler = favoriteButtonHandler
    self.pullDownMenuActionsBuilder = pullDownMenuActionsBuilder
    self.minValue = minValue
    self.maxValue = maxValue
    self.stepValue = stepValue
    self.valueChangeHandled = valueChangeHandled
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
