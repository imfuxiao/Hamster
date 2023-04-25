//
//  LaunchScreen.swift
//  HamsterApp
//
//  Created by morse on 17/3/2023.
//

import SwiftUI

struct LaunchScreen: View {
  init(_ isAppFirstRun: Bool, loadingMessage: Binding<String> = .constant("")) {
    self.isAppFirstRun = isAppFirstRun
    self._loadingMessage = loadingMessage
    if isAppFirstRun {
      self.loadingMessage = "应用首次运行会编译输入方案, 请稍候..."
    }
  }

  let isAppFirstRun: Bool
  @Binding var loadingMessage: String

  @Environment(\.colorScheme) var colorScheme

  @State var start = UnitPoint(x: 0, y: 0)
  @State var end = UnitPoint(x: 1, y: 1)

  let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
  let colors = [
    Color.gray,
    Color.black,
  ]

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor
        .ignoresSafeArea(.all)

      VStack(alignment: .center) {
        Spacer()

        if colorScheme == .dark {
          Image("HamsterWhite")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .opacity(0.8)
        } else {
          Image("Hamster")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .opacity(0.8)
        }

        LinearGradient(
          gradient: Gradient(colors: colors),
          startPoint: start,
          endPoint: end
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 150)
        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false))
        .onReceive(timer, perform: { _ in
          self.start = UnitPoint(x: 2, y: 2)
        })
        .mask(
          VStack {
            Text("仓输入法")
            Text("powered by 中州韻輸入法引擎".uppercased())
              .padding(.top, 3)

            Text(loadingMessage)
              .font(.system(size: 14))
              .padding(.top, 10)
          }
          .font(.system(size: 20, weight: .bold, design: .rounded))
        )

        Spacer()
      }
    }
  }
}

struct LaunchScreen_Previews: PreviewProvider {
  static var previews: some View {
    LaunchScreen(true)
  }
}
