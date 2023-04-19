//
//  InputkeyFuctionView.swift
//  HamsterApp
//
//  Created by morse on 2023/3/20.
//

import SwiftUI

struct InputEditorView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      ScrollView {
        VStack {
          HStack {
            Text("输入功能调整")
              .subViewTitleFont()
            Spacer()
          }
          .padding(.horizontal)
          
          HStack {
            Text("可根据个人爱好修改两个按键对应的键值.")
              .font(.system(size: 12))
              .foregroundColor(.secondary)
            Spacer()
          }
          .padding(.top)
          .padding(.horizontal)
          
          VStack {
            HStack {
              Toggle(isOn: $appSettings.showSpaceLeftButton) {
                Text("空格左边按键")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
            if appSettings.showSpaceLeftButton {
              HStack {
                TextField("空格左边按键", text: $appSettings.spaceLeftButtonValue)
                  .textFieldStyle(BorderTextFieldBackground(systemImageString: "pencil"))
                  .padding(.vertical, 5)
                  .foregroundColor(.secondary)
                Spacer()
              }
            }
          }
          .animation(.linear, value: appSettings.showSpaceLeftButton)
          .functionCell()
          
          VStack {
            HStack {
              Toggle(isOn: $appSettings.showSpaceRightButton) {
                Text("空格右边按键")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
            if appSettings.showSpaceRightButton {
              HStack {
                TextField("空格左边按键", text: $appSettings.spaceRightButtonValue)
                  .textFieldStyle(BorderTextFieldBackground(systemImageString: "pencil"))
                  .padding(.vertical, 5)
                  .foregroundColor(.secondary)
                Spacer()
              }
            }
          }
          .animation(.linear, value: appSettings.showSpaceRightButton)
          .functionCell()
          
          VStack {
            HStack {
              Toggle(isOn: $appSettings.showSpaceRightSwitchLanguageButton) {
                Text("中英切换键")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
            if appSettings.showSpaceRightSwitchLanguageButton {
              HStack {
                Toggle(isOn: $appSettings.switchLanguageButtonInSpaceLeft) {
                  Text("空格左侧:(默认位于右侧)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
              }
            }
          }
          .animation(.linear, value: appSettings.showSpaceRightSwitchLanguageButton)
          .functionCell()
          
          VStack {
            HStack {
              Toggle(isOn: $appSettings.enableKeyboardAutomaticallyLowercase) {
                Text("Shift自动转小写")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
            HStack {
              Text("默认键盘大小写会保持自身状态. 开启此选项后, 当在大写状态在下输入一个字母后会自动转为小写状态. 注意: 双击Shift会保持锁定")
                .font(.system(size: 14))
            }
          }
          .animation(.linear, value: appSettings.showSpaceLeftButton)
          .functionCell()
          
          VStack {
            HStack {
              Toggle(isOn: $appSettings.enableInputEmbeddedMode) {
                Text("候选栏内嵌模式")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
          }
          .animation(.linear, value: appSettings.showSpaceLeftButton)
          .functionCell()
          
          VStack {
            HStack {
              Stepper(value: $appSettings.rimeMaxCandidateSize, in: 50 ... 500, step: 50) {
                Text("候选文字最大数量: \(appSettings.rimeMaxCandidateSize)")
              }
              Spacer()
            }
          }
          .animation(.linear, value: appSettings.showSpaceLeftButton)
          .functionCell()
          
          VStack {
            HStack {
              Stepper(value: $appSettings.rimeCandidateTitleFontSize, in: 18 ... 30, step: 1) {
                Text("候选文字体大小: \(appSettings.rimeCandidateTitleFontSize)")
              }
              Spacer()
            }
          }
          .animation(.linear, value: appSettings.showSpaceLeftButton)
          .functionCell()
          
          Spacer()
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct InputkeyFuctionView_Previews: PreviewProvider {
  static var previews: some View {
    InputEditorView()
      .environmentObject(HamsterAppSettings())
  }
}
