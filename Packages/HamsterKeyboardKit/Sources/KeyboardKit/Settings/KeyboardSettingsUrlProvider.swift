//
//  KeyboardSettingsUrlProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-03-19.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This protocol can be implemented by any type that should be
 able to resolve a URL to an app's keyboard settings page in
 System Settings.

 此协议可以由任何能够解析系统设置中应用程序键盘设置页面 URL 的类型来实现。

 This protocol is implemented by `URL`.

 该协议由 `URL` 实现。
 */
public protocol KeyboardSettingsUrlProvider {}

public extension KeyboardSettingsUrlProvider {
  /**
   The url to the app's settings screen in System Settings.

   If the app has no custom settings screen, this url will
   open the main system settings screen.
   */
  static var keyboardSettings: URL? {
    URL(string: UIApplication.openSettingsURLString)
  }
}

extension URL: KeyboardSettingsUrlProvider {}
