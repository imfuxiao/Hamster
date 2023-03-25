//
//  FeedbackView.swift
//  HamsterApp
//
//  Created by morse on 16/3/2023.
//

import SwiftUI

struct FeedbackView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @State var hapticIntensity: HapticIntensity = .mediumImpact
  @Environment(\.openURL) var openURL
  @Environment(\.colorScheme) var colorScheme

  var hasFullAccess: Bool {
    UIInputViewController().hasFullAccess
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Color.HamsterBackgroundColor.opacity(0.1).ignoresSafeArea()

        VStack {
          HStack {
            Text("键盘反馈")
              .font(.system(size: 30, weight: .black))

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

          VStack {
            HStack {
              Toggle(isOn: $appSettings.enableKeyboardFeedbackHaptic) {
                Text("触感")
                  .font(.system(.body, design: .rounded))
                  .fontWeight(.bold)
              }
            }
            if appSettings.enableKeyboardFeedbackHaptic && !hasFullAccess {}
            if appSettings.enableKeyboardFeedbackHaptic {
              HStack {
                Text("触感强度")
                  .font(.system(.body, design: .rounded))
                  .fontWeight(.bold)
                Spacer()
                Picker("触感强度", selection: $hapticIntensity) {
                  ForEach(HapticIntensity.allCases) {
                    Text($0.text).tag($0)
                  }
                }
              }
            }
          }
          .padding([.all], 15)
          .background(Color.HamsterCellColor)
          .foregroundColor(Color.HamsterFontColor)
          .cornerRadius(8)
          .hamsterShadow()
          .padding(.horizontal)
          .transition(.opacity)
          .animation(.linear, value: appSettings.enableKeyboardFeedbackHaptic)

          Spacer()
        }

        if appSettings.enableKeyboardFeedbackHaptic && !hasFullAccess {
          BlackView(bgColor: .black.opacity(0.1))
            .onTapGesture {
              appSettings.enableKeyboardFeedbackHaptic = false
            }

          VStack(alignment: .center) {
            Spacer()

            VStack {
              Text("因系统限制, 震动需要开启键盘**完全访问权限**.")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 30)
                .padding(.horizontal, 30)

              Spacer()

              HStack(spacing: 60) {
                LongButton(
                  buttonText: "取消",
                  backgroundColor: .gray.opacity(0.5))
                {
                  appSettings.enableKeyboardFeedbackHaptic = false
                }
                LongButton(
                  buttonText: "开启",
                  foregroundColor: .white,
                  backgroundColor: .green.opacity(0.6))
                {
                  // 点击跳转设置
                  openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
              }
              .padding(.bottom, 50)
            }
            .frame(width: proxy.size.width, height: proxy.size.height / 3)
            .background(colorScheme == .dark ? Color.secondary : Color.white)
            .cornerRadius(15)
          }
          .edgesIgnoringSafeArea(.all)
          .animation(.interpolatingSpring(stiffness: 200, damping: 25))
          .transition(.move(edge: .bottom))
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .onChange(of: hapticIntensity, perform: {
        appSettings.keyboardFeedbackHapticIntensity = $0.rawValue
      })
      .onAppear {
        hapticIntensity = HapticIntensity(rawValue: appSettings.keyboardFeedbackHapticIntensity) ?? .mediumImpact
      }
      .onDisappear {
        if !hasFullAccess && appSettings.enableKeyboardFeedbackHaptic {
          appSettings.enableKeyboardFeedbackHaptic = false
        }
      }
    }
  }
}

struct FeedbackView_Previews: PreviewProvider {
  static var previews: some View {
    FeedbackView(hapticIntensity: .mediumImpact)
      .environmentObject(HamsterAppSettings())
  }
}
