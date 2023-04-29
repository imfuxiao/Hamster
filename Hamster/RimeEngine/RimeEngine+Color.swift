//
//  RimeEngine+KeyboardButtonStyle.swift
//  Hamster
//
//  Created by morse on 1/3/2023.
//

import SwiftUI

extension String {
  // RIME配置文件中的颜色为: 24位色值，16进制，BGR顺序
  var bgrColor: Color? {
    if !hasPrefix("0x") {
      return nil
    }

    // 提取 0x 后数字
    let beginIndex = index(startIndex, offsetBy: 2)
    let hexColorStr = String(self[beginIndex...])
    let scanner = Scanner(string: hexColorStr)

    var hexValue: UInt64 = .zero
    var r: CGFloat = .zero
    var g: CGFloat = .zero
    var b: CGFloat = .zero
    var alpha = CGFloat(0xff) / 255

    switch count {
    case 8:
      // sscanf(string.UTF8String, "0x%02x%02x%02x", &b, &g, &r);
      if scanner.scanHexInt64(&hexValue) {
        r = CGFloat(hexValue & 0xff) / 255
        g = CGFloat((hexValue & 0xff00) >> 8) / 255
        b = CGFloat((hexValue & 0xff0000) >> 16) / 255
      }
    case 10:
      // sscanf(string.UTF8String, "0x%02x%02x%02x%02x", &a, &b, &g, &r);
      if scanner.scanHexInt64(&hexValue) {
        r = CGFloat(hexValue & 0xff) / 255
        g = CGFloat((hexValue & 0xff00) >> 8) / 255
        b = CGFloat((hexValue & 0xff0000) >> 16) / 255
        alpha = CGFloat((hexValue & 0xff000000) >> 24) / 255
      }
    default:
      return nil
    }

    return Color(
      red: r,
      green: g,
      blue: b,
      opacity: alpha
    )
  }
}
