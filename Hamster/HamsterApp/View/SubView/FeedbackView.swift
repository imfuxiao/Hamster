//
//  FeedbackView.swift
//  HamsterApp
//
//  Created by morse on 16/3/2023.
//

import SwiftUI

struct FeedbackView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @Environment(\.openURL) var openURL
  @Environment(\.colorScheme) var colorScheme

  @State var hapticIntensity: HapticIntensity = .mediumImpact

  var hasFullAccess: Bool {
    appSettings.hasFullAccess
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Color.HamsterBackgroundColor.ignoresSafeArea()

        VStack(alignment: .center, spacing: 0) {
          HStack {
            Text("键盘反馈")
              .subViewTitleFont()

            Spacer()
          }
          .padding(.horizontal)

          
          VStack {
            HStack {
              Toggle(isOn: $appSettings.enableKeyboardFeedbackSound) {
                Text("声音")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
          }
          .functionCell()
          .padding(.vertical, 10)
          
          VStack {
            HStack {
              Toggle(isOn: $appSettings.enableKeyboardFeedbackHaptic) {
                Text("触感")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
            if appSettings.enableKeyboardFeedbackHaptic {
              HStack {
                Text("触感强度")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Picker("触感强度", selection: $hapticIntensity) {
                  ForEach(HapticIntensity.allCases) {
                    Text($0.text).tag($0)
                  }
                }
                .pickerStyle(.menu)
              }
            }
          }
          .functionCell()
          .animation(.linear, value: appSettings.enableKeyboardFeedbackHaptic)

          Spacer()
        }
        .padding(.horizontal)

        if appSettings.enableKeyboardFeedbackHaptic && !hasFullAccess {
          BlackView(bgColor: .black.opacity(0.1))
            .onTapGesture {
              appSettings.enableKeyboardFeedbackHaptic = false
            }

          VStack(alignment: .center) {
            Spacer()

            VStack {
              Text("因系统限制, 震动需要开启键盘**完全访问权限**.")
                .multilineTextAlignment(.leading)
                .font(.system(size: 18, weight: .bold))
                .minimumScaleFactor(0.6)
                .foregroundColor(.primary)
                .padding(.top, 30)
                .padding(.horizontal, 30)

              Text("点击\"开启\"跳转系统设置, 点击\"键盘 -> 允许完全访问\", 选择\"允许\".")
                .multilineTextAlignment(.leading)
                .font(.system(size: 12, weight: .bold))
                .minimumScaleFactor(0.6)
                .foregroundColor(.secondary)
                .padding(.top, 5)
                .padding(.horizontal, 30)

              Spacer()

              HStack(spacing: 60) {
                LongButton(
                  buttonText: "取消",
                  backgroundColor: .gray
                ) {
                  appSettings.enableKeyboardFeedbackHaptic = false
                }
                LongButton(
                  buttonText: "开启",
                  foregroundColor: .white,
                  backgroundColor: .green
                ) {
                  // 点击跳转设置
                  openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
              }
              .padding(.bottom, 100)
              .padding(.horizontal)
            }
            .frame(width: proxy.size.width, height: proxy.size.height / 3)
            .background(colorScheme == .dark ? Color.secondary : Color.white)
            .cornerRadius(15)
          }
          .zIndex(100)
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
        if !hasFullAccess {
          appSettings.enableKeyboardFeedbackHaptic = false
        }
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
      .environmentObject(HamsterAppSettings.shared)
  }
}
