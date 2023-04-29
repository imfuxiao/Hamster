//
//  HamsterHUD.swift
//  Hamster
//
//  Created by morse on 28/4/2023.
//

import SwiftUI

extension View {
  func hud(isShow: Binding<Bool>, message: Binding<String>) -> some View {
    ZStack {
      self
      if isShow.wrappedValue {
        BlackView(bgColor: .HamsterBackgroundColor)
//          .opacity(0.1)

        VStack {
          Spacer()
          Text(message.wrappedValue)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color.secondary)
          DotsActivityView(dotSize: 30, color: .green)
          Spacer()
        }
        .zIndex(1000000)
      }
    }
  }
}

struct HamsterHUD_Previews: PreviewProvider {
  static var previews: some View {
    Text("HelloWorld")
      .hud(isShow: .constant(true), message: .constant("请稍后..."))
  }
}
