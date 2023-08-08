//
//  SpaceDragSensitivity.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-10.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum can be used to change the drag sensitivity of the
 spacebar.

 该枚举可用于更改空格键的拖动灵敏度。

 `NOTE` The sensitivity value corresponds to how many points
 a spacebar must be dragged for the input cursor to move one
 step. This means that the sensitivity is `inverted`. Higher
 values mean that the cursor moves less.

 `NOTE` 灵敏度值指必须拖动空格键多少 point 才能移动屏幕上的输入光标一步。
 这意味着灵敏度是“颠倒的”。值越高意味着光标移动的越少。
 */
public enum SpaceDragSensitivity: Codable, Identifiable {
  case low, medium, high, custom(points: Int)
}

public extension SpaceDragSensitivity {
  var id: Int { points }

  var points: Int {
    switch self {
    case .low: return 10
    case .medium: return 5
    case .high: return 2
    case .custom(let points): return points
    }
  }
}
