//
//  CGSize+Device.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-10-08.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics

/**
 This extension specifies screen sizes, as they are reported
 when the keyboard prints out the size.

 该扩展指定屏幕尺寸，因为键盘打印尺寸时会报告屏幕尺寸。
 */
public extension CGSize {
  /**
   Whether or not the size is a large iPad Pro screen size
   in portrait orientation.

   纵向的 iPad Pro 大屏幕尺寸。
   */
  static let iPadProLargeScreenPortrait = CGSize(width: 1024, height: 1366)

  /**
   Whether or not the size is a large iPad Pro screen size
   in landscape orientation.

   横向大 iPad Pro 屏幕尺寸。
   */
  static let iPadProLargeScreenLandscape = iPadProLargeScreenPortrait.flipped()

  /**
   Whether or not the size is a small iPad Pro screen size
   in portrait orientation.

   纵向的小型 iPad Pro 屏幕尺寸。
   */
  static let iPadProSmallScreenPortrait = CGSize(width: 834, height: 1194)

  /**
   Whether or not the size is a small iPad Pro screen size
   in landscape orientation.

   横向的小型 iPad Pro 屏幕尺寸。
   */
  static let iPadProSmallScreenLandscape = iPadProSmallScreenPortrait.flipped()

  /**
   Whether or not the size is a "regular" iPad screen size
   in portrait orientation.

   纵向的 "regular" iPad 屏幕尺寸。
   */
  static let iPadScreenPortrait = CGSize(width: 768, height: 1024)

  /**
   Whether or not the size is a "regular" iPad screen size
   in landscape orientation.

   横向 "regular" iPad 屏幕尺寸。
   */
  static let iPadScreenLandscape = iPadScreenPortrait.flipped()

  /**
   Whether or not the size is an iPhone ProMax screen size
   in portrait orientation.

   纵向 iPhone Pro Max 屏幕尺寸。
   */
  static let iPhoneProMaxScreenPortrait = CGSize(width: 428, height: 926)

  /**
   Whether or not the size is an iPhone ProMax screen size
   in landscape orientation.

   横向 iPhone Pro Max 屏幕尺寸
   */
  static let iPhoneProMaxScreenLandscape = iPhoneProMaxScreenPortrait.flipped()

  /**
   Flip the size's height and width.

   翻转尺寸的高度和宽度。
   */
  func flipped() -> CGSize {
    CGSize(width: height, height: width)
  }

  /**
   Whether or not the size matches another screen size, in
   any orientation.

   尺寸是否与任何方向的其他屏幕尺寸相匹配。
   */
  func isScreenSize(_ size: CGSize) -> Bool {
    self == size || self == size.flipped()
  }

  /**
   Whether or not the size matches another screen size, in
   any orientation.

   尺寸是否与任何方向的其他屏幕尺寸相匹配。

   - withTolerance: 容忍度
   */
  func isScreenSize(
    _ size: CGSize,
    withTolerance points: CGFloat
  ) -> Bool {
    self.isEqual(to: size, withTolerance: points) ||
      self.isEqual(to: size.flipped(), withTolerance: points)
  }
}

extension CGSize {
  func isEqual(
    to size: CGSize,
    withTolerance points: CGFloat
  ) -> Bool {
    width.isEqual(to: size.width, withTolerance: points) &&
      height.isEqual(to: size.height, withTolerance: points)
  }
}

extension CGFloat {
  func isEqual(
    to value: CGFloat,
    withTolerance points: CGFloat
  ) -> Bool {
    self > value - points && self < value + points
  }
}
