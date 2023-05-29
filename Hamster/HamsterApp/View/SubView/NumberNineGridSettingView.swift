//
//  NumberNineGridSettingView.swift
//  Hamster
//
//  Created by morse on 2023/5/26.
//

import ProgressHUD
import SwiftUI

/// 数字九宫格设置页面
struct NumberNineGridSettingView: View {
  init() {
    Logger.shared.log.debug("NumberNineGridSettingView init")
  }

  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      VStack {
        HStack {
          Text("数字九宫格设置")
            .subViewTitleFont()
          Spacer()
        }
        .padding(.horizontal)

        VStack {
          HStack {
            Toggle(isOn: $appSettings.enableNumberNineGrid) {
              Text("开启数字九宫格")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            }
          }
        }
        .functionCell()
        .padding(.vertical, 10)

        if appSettings.enableNumberNineGrid {
          VStack {
            HStack {
              Toggle(isOn: $appSettings.enableNumberNineGridInputOnScreenMode) {
                Text("是否直接上屏")
                  .font(.system(size: 16, weight: .bold, design: .rounded))
              }
            }
            HStack {
              Text("开启此选项后，字符与数字会直接上屏，不在经过RIME引擎处理。")
                .font(.system(size: 14))
            }
          }
          .functionCell()
          .padding(.vertical, 10)

          SymbolEditView(symbols: $appSettings.numberNineGridSymbols, title: "九宫格符号")
        }

        Spacer()
      }
      .padding(.horizontal)
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct NumberNineGridSettingView_Previews: PreviewProvider {
  static var previews: some View {
    NumberNineGridSettingView()
      .environmentObject(HamsterAppSettings())
  }
}
