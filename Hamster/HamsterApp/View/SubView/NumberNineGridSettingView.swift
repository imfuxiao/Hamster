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

  @State var tags = ["功能设置", "符号列表"]
  @State var selectTag = 0

  @ViewBuilder
  var settingView: some View {
    VStack {
      VStack {
        HStack {
          Toggle(isOn: $appSettings.enableNumberNineGrid) {
            Text("开启数字九宫格")
              .font(.system(size: 16, weight: .bold, design: .rounded))
          }
        }
      }
      .functionCell()
      .padding(.horizontal)
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
        .padding(.horizontal)
        .padding(.vertical, 10)

        LongButton(
          buttonText: "符号重置"
        ) {
          appSettings.numberNineGridSymbols = HamsterAppSettingKeys.defaultNumberNineGridSymbols
          ProgressHUD.showSuccess("重置成功")
        }
        .padding(.all)
      }
    }
  }

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

        HStack(spacing: 0) {
          Picker(selection: $selectTag, label: Text("")) {
            ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
              Button {
                withAnimation {
                  selectTag = index
                }
              } label: {
                Text(tag)
                  .font(.system(size: 16, weight: .bold))
              }
              .buttonStyle(.plain)
              .tag(index)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)

        if selectTag == 0 {
          settingView
        }

        if selectTag == 1 {
          SymbolEditView(symbols: $appSettings.numberNineGridSymbols, title: "九宫格符号列表设置", moveDisabled: false)
        }

        Spacer()
      }
    }
  }
}

struct NumberNineGridSettingView_Previews: PreviewProvider {
  static var previews: some View {
    NumberNineGridSettingView()
      .environmentObject(HamsterAppSettings())
  }
}
