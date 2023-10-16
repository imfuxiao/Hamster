//
//  KeyboardLayoutConfiguration.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-10-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation
import UIKit

/**
 This type defines layout configurations for various devices,
 given the current screen size and orientation.

 该类型根据当前屏幕尺寸和方向，为各种设备定义布局配置。

 The standard, parameterless configuration can be changed to
 affect the global defaults.

 可以更改无参数的标准配置，以影响全局默认值。
 */
public struct KeyboardLayoutConfiguration: Equatable
{
  /**
   The corner radius of a keyboard button in the keyboard.

   键盘中按键的圆角半径。
   */
  public var buttonCornerRadius: CGFloat

  /**
   The edge insets of a keyboard button in the keyboard.

   键盘中按键的边缘嵌入。
   */
  public var buttonInsets: UIEdgeInsets

  /**
   The total height incl. insets, of a row in the keyboard.

   键盘中单行的总高度（包括嵌入部分）。
   */
  public var rowHeight: CGFloat

  /**
    Create a new layout configuration.

    创建新的布局配置。

    - Parameters:
      - buttonCornerRadius: The corner radius of a keyboard button in the keyboard.
      - buttonInsets: The edge insets of a keyboard button in the keyboard.
      - rowHeight: The total height incl. insets, of a row in the keyboard.
   */
  public init(
    buttonCornerRadius: CGFloat,
    buttonInsets: UIEdgeInsets,
    rowHeight: CGFloat)
  {
    self.buttonCornerRadius = buttonCornerRadius
    self.buttonInsets = buttonInsets
    self.rowHeight = rowHeight
  }
}

public extension KeyboardLayoutConfiguration
{
  /**
   The standard config for the provided `context`.

   根据提供的 `context` 的生成标准配置。
   */
  static func standard(
    for context: KeyboardContext
  ) -> KeyboardLayoutConfiguration
  {
    standard(
      forDevice: context.isKeyboardFloating ? .phone : context.deviceType,
      screenSize: context.screenSize,
      orientation: context.interfaceOrientation)
  }

  /**
   The standard config for the provided device and screen.

   尴所提供设备和屏幕参数, 生成标准配置。
   */
  static func standard(
    forDevice device: DeviceType,
    screenSize size: CGSize,
    orientation: InterfaceOrientation) -> KeyboardLayoutConfiguration
  {
    switch device
    {
    case .pad: return standardPad(forScreenSize: size, orientation: orientation)
    default: return standardPhone(forScreenSize: size, orientation: orientation)
    }
  }

  /**
   The standard pad config for the provided `screen`.

   根据所提供 `screen`，生成标准 pad 配置。
   */
  static func standardPad(
    forScreenSize size: CGSize,
    orientation: InterfaceOrientation) -> KeyboardLayoutConfiguration
  {
    let isPortrait = orientation.isPortrait
    if size.isScreenSize(.iPadProLargeScreenPortrait)
    {
      return isPortrait ? .standardPadProLarge : .standardPadProLargeLandscape
    }
    return isPortrait ? .standardPad : .standardPadLandscape
  }

  /**
   The standard phone config for the provided `screen`.

   根据所提供 `screen`，生成标准 phone 配置。
   */
  static func standardPhone(
    forScreenSize size: CGSize,
    orientation: InterfaceOrientation) -> KeyboardLayoutConfiguration
  {
    let isPortrait = orientation.isPortrait
    if size.isEqual(to: .iPhoneProMaxScreenPortrait, withTolerance: 10)
    {
      return isPortrait ? .standardPhoneProMax : .standardPhoneProMaxLandscape
    }
    return isPortrait ? .standardPhone : .standardPhoneLandscape
  }

  /**
   The standard config for an iPad in portait.

   iPad 纵向的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPad = KeyboardLayoutConfiguration(
    buttonCornerRadius: 5,
    buttonInsets: .horizontal(6, vertical: 4),
    rowHeight: standardPadRowHeight)

  /**
   The standard iPad portait row height.

   标准 iPad 纵向行高。
   */
  static let standardPadRowHeight = 64.0

  /**
   The standard config for an iPad in landscape.

   横向 iPad 的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPadLandscape = KeyboardLayoutConfiguration(
    buttonCornerRadius: 7,
    buttonInsets: .horizontal(7, vertical: 6),
    rowHeight: standardPadLandscapeRowHeight)

  /**
   The standard iPad landscape row height.

   标准 iPad 横向行高度。
   */
  static let standardPadLandscapeRowHeight = 86.0

  /**
   The standard config for a large iPad Pro in portrait.

   大型 iPad Pro 纵向的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPadProLarge = KeyboardLayoutConfiguration(
    buttonCornerRadius: 6,
    buttonInsets: .horizontal(4, vertical: 4),
    rowHeight: standardPadProLargeRowHeight)

  /**
   The standard large iPad Pro portrait row height.

   标准大尺寸 iPad Pro 纵向行高度。
   */
  static let standardPadProLargeRowHeight = 69.0

  /**
   The standard config for a large iPad Pro in landscape.

   大型 iPad Pro 横向的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPadProLargeLandscape = KeyboardLayoutConfiguration(
    buttonCornerRadius: 8,
    buttonInsets: .horizontal(7, vertical: 5),
    rowHeight: standardPadProLargeLandscapeRowHeight)

  /**
   The standard large iPad Pro landscape row height.

   标准大尺寸 iPad Pro 横向行高度。
   */
  static let standardPadProLargeLandscapeRowHeight = 88.0

  /**
   The standard config for an iPhone in portrait.

   纵向 iPhone 的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPhone = KeyboardLayoutConfiguration(
    buttonCornerRadius: 5,
    buttonInsets: .horizontal(3, vertical: 6),
    rowHeight: standardPhoneRowHeight)

  /**
   The standard iPhone portrait row height.

   标准的 iPhone 纵向行高。
   */
  static var standardPhoneRowHeight = 54.0

  /**
   The standard config for an iPhone in landscape.

   横向 iPhone 的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPhoneLandscape = KeyboardLayoutConfiguration(
    buttonCornerRadius: 5,
    buttonInsets: .horizontal(3, vertical: 4),
    rowHeight: standardPhoneLandscapeRowHeight)

  /**
   The standard iPhone landscape row height.

   标准的 iPhone 横向行高。
   */
  static var standardPhoneLandscapeRowHeight = 40.0

  /**
   The standard config for an iPhone Pro Max in portrait.

   纵向 iPhone Pro Max 的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPhoneProMax = KeyboardLayoutConfiguration(
    buttonCornerRadius: 5,
    buttonInsets: .horizontal(3, vertical: 5.5),
    rowHeight: standardPhoneProMaxRowHeight)

  /**
   The standard iPhone Pro Max portrait row height.

   标准 iPhone Pro Max 纵向行高
   */
  static var standardPhoneProMaxRowHeight = 56.0

  /**
   The standard config for an iPhone Pro Max in landscape.

   横向 iPhone Pro Max 的标准配置。

   You can change this value to affect the global default.

   您可以更改该值以影响全局默认值。
   */
  static var standardPhoneProMaxLandscape = KeyboardLayoutConfiguration(
    buttonCornerRadius: 5,
    buttonInsets: .horizontal(3, vertical: 4),
    rowHeight: standardPhoneProMaxLandscapeRowHeight)

  /**
   The standard iPhone Pro Max Landscape row height.

   标准 iPhone Pro Max 横向行高。
   */
  static var standardPhoneProMaxLandscapeRowHeight = 40.0
}
