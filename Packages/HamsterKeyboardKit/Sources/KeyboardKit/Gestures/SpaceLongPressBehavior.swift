//
//  SpaceLongPressBehavior.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-02-21.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum defines various space key long press actions.

 该枚举定义了各种空格键长按操作。
 */
public enum SpaceLongPressBehavior: Codable {
  /// Long pressing space starts moving the input cursor.
  ///
  /// 长按空格键开始移动输入光标。
  ///
  /// This is the default behavior in native iOS keyboards.
  /// 这是 iOS 原生键盘的默认行为。
  case moveInputCursor

  /// Long pressing space opens a locale context menu.
  ///
  /// 长按空格键可打开本地化上下文菜单。
  ///
  /// Only use this when you think that really makes sense.
  /// Long pressing space to start moving the input cursor
  /// is the default and expected behavior.
  ///
  /// 只有当你认为这样做有意义时才会使用。长按空格开始移动输入光标是默认的预期行为。
  case openLocaleContextMenu
}
