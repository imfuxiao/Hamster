//
//  SettingSectionModel.swift
//
//
//  Created by morse on 2023/7/5.
//

import Foundation

public struct SettingSectionModel: Hashable {
  public var title: String
  public var footer: String?
  public var items: [SettingItemModel]

  init(title: String = "", footer: String? = nil, items: [SettingItemModel]) {
    self.title = title
    self.footer = footer
    self.items = items
  }
}
