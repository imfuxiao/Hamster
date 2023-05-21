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

          Section {
            List {
              ForEach(appSettings.numberNineGridSymbols, id: \.self) { symbol in
                VStack(spacing: 0) {
                  Spacer()
                  HStack(spacing: 0) {
                    if let index = index(symbol) {
                      TextField(symbol, text: $appSettings.numberNineGridSymbols[index])
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                    }

                    Spacer()

                    if #available(iOS 15, *) {
                      Image(systemName: "line.3.horizontal")
                    } else {
                      Image(systemName: "pencil")
                    }
                  }
                  .padding(.horizontal)
                  .padding(.vertical, 3)
                  Spacer()
                  Divider()
                }
                .hideListRowSeparator()
                .listRowBackground(Color.HamsterBackgroundColor)
              }
              .onMove(perform: move)
              .onDelete(perform: delete)
            }
            .listStyle(.plain)
          } header: {
            HStack(spacing: 0) {
              Text("自定义符号栏")
              Spacer()
              Button {
                addEmptySymbol()
              } label: {
                Image(systemName: "plus")
              }
            }
            .padding(.horizontal)
          }
        }

        Spacer()
      }
      .padding(.horizontal)
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

extension NumberNineGridSettingView {
  func index(_ symbol: String) -> Int? {
    if let index = appSettings.numberNineGridSymbols.firstIndex(of: symbol) {
      return index
    }
    return nil
  }

  func move(from source: IndexSet, to destination: Int) {
    appSettings.numberNineGridSymbols.move(fromOffsets: source, toOffset: destination)
  }

  func delete(from source: IndexSet) {
    appSettings.numberNineGridSymbols.remove(atOffsets: source)
  }

  func addEmptySymbol() {
    if let _ = appSettings.numberNineGridSymbols.first(where: { $0 == "" }) {
      ProgressHUD.showError("请先修改值为空的符号")
      return
    }
    appSettings.numberNineGridSymbols.append("")
  }
}

struct NumberNineGridSettingView_Previews: PreviewProvider {
  static var previews: some View {
    NumberNineGridSettingView()
      .environmentObject(HamsterAppSettings())
  }
}
