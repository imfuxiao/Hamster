//
//  GestureButtonDefaults.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2022-11-24.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 该结构体可用于配置手势的默认值。
 */
public enum GestureButtonDefaults {
  /// The max time between two taps for them to count as a double tap, by default `0.2`.
  ///
  /// 双击的两次点击之间最大间隔时间，默认为 `0.2`。单位：秒
  public static var doubleTapTimeout = 0.2

  /// The time it takes for a press to count as a long press, by default `0.5`.
  ///
  /// 识别长按所需的时间，默认为 `0.5`。
  public static var longPressDelay = 0.5

  /// The time it takes for a press to count as a repeat trigger, by default `0.5`.
  ///
  /// 重复触发的所需时间，默认为 `0.5`。
  public static var repeatDelay = 0.5
}
