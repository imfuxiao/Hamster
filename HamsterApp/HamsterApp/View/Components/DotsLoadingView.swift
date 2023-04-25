//
//  DotLoadingView.swift
//  HamsterApp
//
//  Created by morse on 2023/3/20.
//

import SwiftUI

struct DotsLoadingView: View {
  @Environment(\.colorScheme) var colorScheme
  let text: String
  let dotColor: Color

  init(text: String, dotColor: Color = .init("dots")) {
    self.text = text
    self.dotColor = dotColor
  }

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor
//        .opacity(colorScheme == .dark ? 0.6 : 0.1)
        .ignoresSafeArea()

      VStack {
        Spacer()
        Text(text)
          .font(.system(size: 20, weight: .bold))
          .foregroundColor(Color.secondary)
        DotsActivityView(color: dotColor)
        Spacer()
      }
    }
  }
}

struct DotsLoadindView_Preview: PreviewProvider {
  static var previews: some View {
    DotsLoadingView(text: "重置中,请稍候...")
  }
}
