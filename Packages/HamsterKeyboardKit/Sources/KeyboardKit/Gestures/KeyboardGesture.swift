//
//  KeyboardGesture.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-10-15.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum defines the various ways a user can interact with
 keyboard actions, using KeyboardKit's built-in interactions.

 该枚举定义了用户使用 KeyboardKit 内置交互与键盘操作进行交互的各种方式。
 */
public enum KeyboardGesture: String, CaseIterable, Codable, Equatable, Identifiable {
  /// Triggers when a button is double tapped.
  ///
  /// 双击按键时触发。
  case doubleTap

  /// Triggers when a button is pressed down.
  ///
  /// 按下按键时触发。
  case press

  /// Triggers when a button is released.
  ///
  /// 释放按键时触发。
  case release

  /// Triggers when a button is long pressed.
  ///
  /// 长按按键时触发。
  case longPress

  /// Triggers repeatedly when a button is pressed & held.
  ///
  /// 按住按钮时重复触发。
  case repeatPress
}

public extension KeyboardGesture {
  /**
   The gesture's unique identifier.

   KeyboardGesture 的唯一标识符。
   */
  var id: String { rawValue }
}
