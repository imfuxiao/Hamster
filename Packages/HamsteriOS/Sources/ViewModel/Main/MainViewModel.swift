//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Combine
import Foundation
import HamsterKit

public class MainViewModel: ObservableObject {
  public let subViewSubject = PassthroughSubject<SettingsSubView, Never>()
  public var subViewPublished: AnyPublisher<SettingsSubView, Never> {
    subViewSubject.eraseToAnyPublisher()
  }

  public let shortcutItemTypeSubject = PassthroughSubject<ShortcutItemType, Never>()
  public var shortcutItemTypePublished: AnyPublisher<ShortcutItemType, Never> {
    shortcutItemTypeSubject.eraseToAnyPublisher()
  }

  /// 导航到输入方案页面
  public func navigationToInputSchema() {
    subViewSubject.send(.inputSchema)
  }

  /// 导航到 RIME 设置页面
  public func navigationToRIME() {
    subViewSubject.send(.rime)
  }

  public func execShortcutCommand(_ shortItemType: ShortcutItemType) {
    shortcutItemTypeSubject.send(shortItemType)
  }

  public func navigation(_ subView: SettingsSubView) {
    subViewSubject.send(subView)
  }
}
