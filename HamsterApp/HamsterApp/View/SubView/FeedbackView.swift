//
//  FeedbackView.swift
//  HamsterApp
//
//  Created by morse on 16/3/2023.
//

import SwiftUI

struct FeedbackView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.opacity(0.1).ignoresSafeArea()

      VStack {
        HStack {
          Text("键盘反馈")
            .font(.system(.title3, design: .rounded))
            .fontWeight(.bold)

          Spacer()
        }
        .padding(.horizontal)

        HStack {
          Toggle(isOn: $appSettings.enableKeyboardFeedbackSound) {
            Text("声音")
              .font(.system(.body, design: .rounded))
              .fontWeight(.bold)
          }
        }
        .padding([.all], 15)
        .background(Color.HamsterCellColor)
        .foregroundColor(Color.HamsterFontColor)
        .cornerRadius(8)
        .hamsterShadow()
        .padding(.horizontal)
        .padding(.bottom, 10)

        HStack {
          Toggle(isOn: $appSettings.enableKeyboardFeedbackHaptic) {
            Text("触感")
              .font(.system(.body, design: .rounded))
              .fontWeight(.bold)
          }
        }
        .padding([.all], 15)
        .background(Color.HamsterCellColor)
        .foregroundColor(Color.HamsterFontColor)
        .cornerRadius(8)
        .hamsterShadow()
        .padding(.horizontal)

        Spacer()
      }
    }
  }
}

struct FeedbackView_Previews: PreviewProvider {
  static var previews: some View {
    FeedbackView()
      .environmentObject(HamsterAppSettings())
  }
}
