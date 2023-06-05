//
//  InterfaceOrientation.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-01-05.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This enum can be used to specify an interface orientation.

 该枚举可用于指定设备界面方向。

 The static ``current`` property will resolve to the current
 interface orientation.

 static 的 ``current`` 属性将解析为当前界面方向。
 */
public enum InterfaceOrientation: String, CaseIterable, Equatable {
  // 纵向
  case portrait
  // 颠倒的纵向
  case portraitUpsideDown

  // 横向
  case landscape, landscapeLeft, landscapeRight

  case unknown
}

public extension InterfaceOrientation {
  /**
   Get the current interface orientation.

   获取当前界面方向。
   */
  static var current: InterfaceOrientation {
    UIScreen.main.interfaceOrientation
  }

  /**
   Whether or not the orientation is a landscape one.

   方向是否为横向。
   */
  var isLandscape: Bool {
    switch self {
    case .portrait, .portraitUpsideDown: return false
    case .landscape, .landscapeLeft, .landscapeRight: return true
    case .unknown: return false
    }
  }

  /**
   Whether or not the orientation is a portrait one.

   方向是否为纵向。
   */
  var isPortrait: Bool {
    switch self {
    case .portrait, .portraitUpsideDown: return true
    case .landscape, .landscapeLeft, .landscapeRight: return false
    case .unknown: return false
    }
  }
}
