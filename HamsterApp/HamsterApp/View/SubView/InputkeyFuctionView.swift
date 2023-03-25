//
//  InputkeyFuctionView.swift
//  HamsterApp
//
//  Created by morse on 2023/3/20.
//

import SwiftUI

struct InputkeyFuctionView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.opacity(0.1).ignoresSafeArea()

      VStack {
        HStack {
          Text("输入功能键设置")
            .font(.system(size: 30, weight: .black))
          Spacer()
        }
        .padding(.horizontal)

        // 反查键
        VStack {
          HStack {
            Toggle(isOn: $appSettings.showKeyboardReverseLookupButton) {
              Text("启用反查键(空格左边)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            }
          }
          if appSettings.showKeyboardReverseLookupButton {
            HStack {
              TextField("反查键键值", text: $appSettings.keyboardReverseLookupButtonValue)
                .textFieldStyle(BorderTextFieldBackground(systemImageString: "pencil"))
                .padding(.vertical, 5)
                .foregroundColor(.secondary)
              Spacer()
            }
            HStack {
              Text("注意: 此键值依赖输入方案配置文件中的配置, 否则没有效果.")
                .font(.footnote)
                .foregroundColor(.secondary)
              Spacer()
            }
          }
        }
        .padding([.all], 15)
        .background(Color.HamsterCellColor)
        .foregroundColor(Color.HamsterFontColor)
        .cornerRadius(8)
        .hamsterShadow()
        .padding(.horizontal)

        // 次选上屏键
        VStack {
          HStack {
            Toggle(isOn: $appSettings.showKeyboardSelectSecondChoiceButton) {
              Text("次选上屏键(回车键上方)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            }
          }
          if appSettings.showKeyboardSelectSecondChoiceButton {
            HStack {
              TextField("次选上屏键", text: $appSettings.keyboardSelectSecondChoiceButtonValue)
                .textFieldStyle(BorderTextFieldBackground(systemImageString: "pencil"))
                .padding(.vertical, 5)
                .foregroundColor(.secondary)
              Spacer()
            }
            HStack {
              Text("注意: 此键值依赖输入方案配置文件中的配置, 否则没有效果.")
                .font(.footnote)
                .foregroundColor(.secondary)
              Spacer()
            }
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
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct InputkeyFuctionView_Previews: PreviewProvider {
  static var previews: some View {
    InputkeyFuctionView()
      .environmentObject(HamsterAppSettings())
  }
}
