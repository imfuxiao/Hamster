//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Foundation
import HamsterKit

public class MainViewModel: ObservableObject {
  @Published
  public var subView: SettingsSubView = .none

  @Published
  public var shortcutItemType: ShortcutItemType = .none

  /// 导航到输入方案页面
  public func navigationToInputSchema() {
    subView = .inputSchema
  }

  /// 导航到 RIME 设置页面
  public func navigationToRIME() {
    subView = .rime
  }

  public func execShortcutCommand(_ shortItemType: ShortcutItemType) {
    shortcutItemType = shortItemType
  }
}
