//
//  CalloutActionProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to get callout actions for a keyboard action.

 该协议可以由任何可用于获取键盘操作的呼出操作的类来实现。
 */
public protocol CalloutActionProvider {
  /**
   Get callout actions for the provided `action`.

   为提供的 `action` 获取呼出操作。

   These actions are presented in a callout when a user is
   long pressing this action.

   当用户长按该操作时，这些操作会在呼出中显示。
   */
  func calloutActions(for action: KeyboardAction) -> [KeyboardAction]
}
