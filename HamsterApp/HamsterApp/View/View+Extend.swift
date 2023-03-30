//
//  View+Extend.swift
//  HamsterApp
//
//  Created by morse on 2023/3/23.
//

import SwiftUI

extension View {
  func hamsterShadow() -> some View {
    return shadow(color: Color.HamsterShadowColor, radius: 1)
  }
}

@available(iOS 14.0, *)
extension EnvironmentValues {
    var dismiss: () -> Void {
        { presentationMode.wrappedValue.dismiss() }
    }
}
