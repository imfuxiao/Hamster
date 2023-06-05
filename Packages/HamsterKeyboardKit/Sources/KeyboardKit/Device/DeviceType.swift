//
//  DeviceType.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2022-01-19.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//
import UIKit

/**
 This enum can be used to specify a device type.

 该 enum 可用于指定设备类型。

 The static ``current`` property will resolve to the current
 device type.

 static ``current`` 属性将解析为当前设备类型。
 */
public enum DeviceType: String, CaseIterable, Equatable {
  case phone, pad, watch, mac, tv, other
}

public extension DeviceType {
  /**
   Get the current device type.

   获取当前设备类型。
   */
  static var current: DeviceType {
    UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? .pad : .phone
  }
}
