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
public enum KeyboardGesture: Codable, Equatable, Identifiable {
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

  /// 上划
  case swipeUp(KeySwipe)

  /// 下划
  case swipeDown(KeySwipe)

  /// 左划
  case swipeLeft(KeySwipe)

  /// 右划
  case swipeRight(KeySwipe)
}

public extension KeyboardGesture {
  /**
   The gesture's unique identifier.

   KeyboardGesture 的唯一标识符。
   */
  var id: String {
    switch self {
    case .doubleTap: return "doubleTap"
    case .press: return "press"
    case .release: return "release"
    case .longPress: return "longPress"
    case .repeatPress: return "repeatPress"
    case .swipeUp(let keySwipe): return "swipeUp(\(keySwipe.hashValue))"
    case .swipeDown(let keySwipe): return "SwipeDown(\(keySwipe.hashValue))"
    case .swipeLeft(let keySwipe): return "swipeUp(\(keySwipe.hashValue))"
    case .swipeRight(let keySwipe): return "SwipeDown(\(keySwipe.hashValue))"
    }
  }

  var isSwipe: Bool {
    switch self {
    case .swipeUp, .swipeDown, .swipeLeft, .swipeRight: return true
    default: return false
    }
  }
}
