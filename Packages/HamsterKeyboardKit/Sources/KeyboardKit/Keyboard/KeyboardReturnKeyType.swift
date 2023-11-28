//
//  KeyboardReturnKeyType.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-04-17.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This enum defines various keyboard return button types that
 can be used as ``KeyboardAction/primary(_:)`` actions.

 此 enum 定义了可用作 ``KeyboardAction/primary(_:)`` 操作的各种键盘 return 按钮类型。

 Return buttons should insert a new line, which will then be
 handled differently depending on the keyboard context. Some
 places will insert the new line, while other places use the
 new line to perform a primary action.

 回车键应插入新行，然后根据键盘上下文进行不同的处理。有些地方会插入新行，而有些地方则执行 primary action。

 This is a multi-platform version of `UIReturnKeyType` which
 has a `keyboardReturnKeyType` extension for mapping.

 这是 `UIReturnKeyType` 的多平台版本，其中有用于映射的 `keyboardReturnKeyType` 的 extension。
 */
public enum KeyboardReturnKeyType: CaseIterable, Codable, Hashable, Identifiable {
  /// A return key that uses a return text and not an ⏎ icon.
  ///
  /// "换行"键, 表示文本换行
  case `return`

  /// A done key used in e.g. Calendar, when adding a location.
  ///
  /// "完成"键, 例如添加位置时的日历。
  case done

  /// A go key used in e.g. Mobile Safari, when entering a url.
  ///
  /// "前往"键，例如 Safari 等浏览器中输入网址后打开网页的按键。
  case go

  /// A join key used in e.g. System Settings, when joining a wifi network with password.
  ///
  /// "加入"键，例如在使用密码加入 WIFI 网络时的系统设置
  case join

  /// A return key that by default uses a ⏎ icon instead of return text.
  ///
  /// 回车键，默认情况, 键盘 UI 会使用 ⏎ 图标表示该键
  case newLine

  /// A next key used in e.g. System Settings, when joining an enterprise wifi network with username and password.
  ///
  /// "下一个"键, 例如系统设置，使用用户名和密码加入企业 WiFi 网络时
  case next

  /// An ok key, which isn't actually used in native.
  ///
  /// "确定"键，实际上在本地语言中并不使用。
  case ok

  /// A search key used in e.g. Mobile Safari, when typing in the google.com search field.
  ///
  /// "搜索"键，例如在 Safari 的 google.com 网页的搜索字段
  case search

  /// A send key used in e.g. some messaging apps (WeChat, QQ etc.) when typing in a chat text field.
  ///
  /// "发送"键，在某些信息应用程序（微信、QQ 等）的聊天文本字段中输入时使用
  case send

  /// A custom key with a custom title.
  ///
  /// 带有自定义 title 的自定义按键。
  case custom(title: String)

  /**
   All unique primary keyboard action types, excluding ``KeyboardAction/custom(named:)``.

   所有 primary keyboard action 类型，不包括``KeyboardAction/custom(named:)``。
   */
  public static var allCases: [KeyboardReturnKeyType] {
    [.return, .done, .go, .join, .newLine, .next, .ok, .search, .send]
  }
}

public extension KeyboardReturnKeyType {
  /**
   The type's unique identifier.

   KeyboardReturnKeyType 的唯一标识符。
   */
  var id: String {
    switch self {
    case .return: return "return"
    case .done: return "done"
    case .go: return "go"
    case .join: return "join"
    case .newLine: return "newLine"
    case .next: return "next"
    case .ok: return "ok"
    case .search: return "search"
    case .send: return "send"
    case .custom(let title): return title
    }
  }

  /**
   Whether or not the action is a system action.

   该 action 是否为系统 action。

   A system action is by default rendered as a dark button.

   默认情况下，系统 action 会呈现为一个深色按钮。
   */
  var isSystemAction: Bool {
    switch self {
    case .return: return true
    case .newLine: return true
    default: return false
    }
  }

  /**
   The standard button to image for a certain locale.

   某个区域的标准 Image 按钮。
   */
  func standardButtonImage(for locale: Locale) -> UIImage? {
    switch self {
    case .newLine: return HamsterUIImage.shared.keyboardNewline(for: locale)
    default: return nil
    }
  }

  /**
   The standard button to text for a certain locale.

   某个区域的标准文本按钮。
   */
  func standardButtonText(for locale: Locale) -> String? {
    switch self {
    case .custom(let title): return title
//    case .done: return KKL10n.done.text(for: locale)
//    case .go: return KKL10n.go.text(for: locale)
//    case .join: return KKL10n.join.text(for: locale)
//    case .newLine: return nil
//    case .next: return KKL10n.next.text(for: locale)
//    case .return: return KKL10n.return.text(for: locale)
//    case .ok: return KKL10n.ok.text(for: locale)
//    case .search: return KKL10n.search.text(for: locale)
//    case .send: return KKL10n.send.text(for: locale)
    case .done: return "完成"
    case .go: return "前往"
    case .join: return "加入"
    case .newLine: return nil
    case .next: return "next"
    case .return: return "换行"
    case .ok: return "确定"
    case .search: return "搜索"
    case .send: return "发送"
    }
  }

  func standardButtonText() -> String? {
    switch self {
    case .custom(let title): return title
    case .done: return "完成"
    case .go: return "前往"
    case .join: return "加入"
    case .newLine: return nil
    case .next: return "next"
    case .return: return "换行"
    case .ok: return "确定"
    case .search: return "搜索"
    case .send: return "发送"
    }
  }
}
