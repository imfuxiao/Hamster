//
//  Keyboard+Preview.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-28.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

public extension KeyboardInputViewController {
  /**
   This preview controller can be used in SwiftUI/UIKit previews.

   该预览控制器可用于 SwiftUI/UIKit 预览。
   */
  static var preview: KeyboardInputViewController {
    KeyboardInputViewController()
  }
}

public extension KeyboardContext {
  /**
   This preview context can be used in SwiftUI/UIKit previews.

   此预览上下文可用于 SwiftUI/UIKit 预览。
   */
  static var preview: KeyboardContext {
    KeyboardContext(controller: KeyboardInputViewController.preview)
  }
}
