//
//  NextKeyboardController.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-01-25.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This class is used as global state for next keyboard button
 views, since they need an input view controller to function.

 该类用作下一个键盘按钮视图的全局状态，因为它们需要 InputViewController 才能运行。

 The KeyboardKit-specific ``KeyboardInputViewController`` is
 automatically setting itself to the shared instance when it
 is loaded in `viewDidLoad`.

 特定于 KeyboardKit 的 ``KeyboardInputViewController``
 在 `viewDidLoad` 中加载时会自动将 self 设置为共享实例。
 */
public final class NextKeyboardController {
  private init() {}

  public weak static var shared: UIInputViewController?
}
