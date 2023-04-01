//
//  View+Extend.swift
//  HamsterApp
//
//  Created by morse on 2023/3/23.
//

import SwiftUI

extension View {
  // 统一阴影样式
  func hamsterShadow() -> some View {
    shadow(color: Color.HamsterShadowColor, radius: 1)
  }

  // 统一子页面Title字体样式
  func subViewTitleFont() -> some View {
    font(.system(size: 26, weight: .black))
  }
}

@available(iOS 14.0, *)
extension EnvironmentValues {
  var dismiss: () -> Void {
    { presentationMode.wrappedValue.dismiss() }
  }
}
