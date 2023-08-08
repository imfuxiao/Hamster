//
//  InterfaceOrientationResolver.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-01-05.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This protocol can be implemented by any types that can find
 out the current interface orientation.

 该协议可以由任何能够找到当前界面方向的类型来实现。

 This protocol is implemented by `UIScreen` in `UIKit`.
 */
protocol InterfaceOrientationResolver {
  /**
   Get the current interface orientation

   获取当前界面方向
   */
  var interfaceOrientation: InterfaceOrientation { get }
}

// MARK: - UIScreen

extension UIScreen: InterfaceOrientationResolver {}

extension UIScreen {
  /**
   Get the current interface orientation.

   获取当前界面方向

   This is required since keyboard extensions cannot check
   the status bar style of the application.

   由于键盘扩展应用无法检查应用程序的状态栏样式，因此需要这样做。
   */
  var interfaceOrientation: InterfaceOrientation {
    // 转换为固定的坐标
    let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
    switch (point.x, point.y) {
    case (0, 0): return .portrait
    case let (x, y) where x != 0 && y != 0: return .portraitUpsideDown
    case let (0, y) where y != 0: return .landscapeLeft
    case let (x, 0) where x != 0: return .landscapeRight
    default: return .unknown
    }
  }
}
