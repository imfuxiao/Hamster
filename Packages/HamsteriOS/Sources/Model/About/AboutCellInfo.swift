//
//  AboutCellInfo.swift
//
//
//  Created by morse on 2023/7/7.
//

import UIKit

public struct AboutCellInfo {
  let text: String
  let secondaryText: String?
  let cellType: AboutCellType
  let typeValue: String?
  let accessoryType: UITableViewCell.AccessoryType?
  let navigationAction: (() -> Void)?

  init(text: String, secondaryText: String? = nil, type: AboutCellType = .copy, typeValue: String? = nil, accessoryType: UITableViewCell.AccessoryType? = nil, navigationAction: (() -> Void)? = nil) {
    self.text = text
    self.secondaryText = secondaryText
    self.cellType = type
    self.typeValue = typeValue
    self.accessoryType = accessoryType
    self.navigationAction = navigationAction
  }
}
