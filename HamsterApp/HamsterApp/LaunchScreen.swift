//
//  LaunchScreen.swift
//  HamsterApp
//
//  Created by morse on 17/3/2023.
//

import SwiftUI

struct LaunchScreen: View {
  @Environment(\.colorScheme) var colorScheme

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
//            .background(
//              RoundedRectangle(cornerRadius: 15)
//                .stroke(lineWidth: 3)
//                .fill(Color.HamsterShadowColor.opacity(0.5))
//            )
        } else {
          Image("Hamster")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
//            .background(
//              RoundedRectangle(cornerRadius: 15)
//                .stroke(lineWidth: 3)
//                .opacity(0.8)
//            )
            .opacity(0.8)
        }

        HStack {
          Text("仓输入法")
            .font(.system(size: 24, weight: .bold))
            .padding(.top, 10)
        }

        Spacer()

        HStack {
          Text("powered by Rime".uppercased())
            .font(.system(size: 18, weight: .bold))
        }
        .padding(.bottom, 10)
      }
    }
  }
}

struct LaunchScreen_Previews: PreviewProvider {
  static var previews: some View {
    LaunchScreen()
  }
}
