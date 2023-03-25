//
//  LaunchScreen.swift
//  HamsterApp
//
//  Created by morse on 17/3/2023.
//

import SwiftUI

struct LaunchScreen: View {
  @Environment(\.colorScheme) var colorScheme

  @State var start = UnitPoint(x: 0, y: 0)
  @State var end = UnitPoint(x: 1, y: 1)

  let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
  let colors = [
    Color.gray.opacity(0.5),
    Color.black,
  ]

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor
        .opacity(0.1)
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
        .frame(height: 80)
        .animation(.easeOut(duration: 2).repeatForever(autoreverses: false))
        .onReceive(timer, perform: { _ in
          self.start = UnitPoint(x: 1, y: 1)
        })
        .mask(
          VStack {
            Text("仓输入法")
            Text("powered by 中州韻輸入法引擎(RIME)".uppercased())
              .padding(.top, 3)
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
    LaunchScreen()
  }
}
