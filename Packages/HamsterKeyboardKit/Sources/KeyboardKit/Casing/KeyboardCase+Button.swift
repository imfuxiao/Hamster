//
//  KeyboardCase+Button.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-07-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import UIKit

public extension KeyboardCase {
  /**
   The casing's standard button image.

   键盘 Shift 按键不同状态对应的图像
   */
  var standardButtonImage: UIImage {
    switch self {
    case .auto: return .keyboardShiftLowercased
    case .capsLocked: return .keyboardShiftCapslocked
    case .lowercased: return .keyboardShiftLowercased
    case .uppercased: return .keyboardShiftUppercased
    }
  }
}
