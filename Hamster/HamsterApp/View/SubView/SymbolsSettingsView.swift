//
//  SymbolsSettingsView.swift
//  Hamster
//
//  Created by morse on 2023/5/29.
//

import ProgressHUD
import SwiftUI

struct SymbolsSettingsView: View {
  init() {
    Logger.shared.log.debug("SymbolsSettingsView init")
  }

  @EnvironmentObject var appSettings: HamsterAppSettings

  @State var tags = ["光标回退", "返回主键盘"]
  @State var selectTag = 0

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      VStack {
        HStack {
          Text("符号功能设置")
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

        HStack {
          if selectTag == 0 {
            SymbolEditView(symbols: $appSettings.cursorBackOfSymbols, title: "光标回退的符号")
          }

          if selectTag == 1 {
            SymbolEditView(symbols: $appSettings.returnToPrimaryKeyboardOfSymbols, title: "返回主键盘的符号")
          }
        }
      }
    }
  }
}

struct SymbolsSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SymbolsSettingsView()
      .environmentObject(HamsterAppSettings())
  }
}

struct SymbolEditView: View {
  @Binding var symbols: [String]
  var title: String

  var body: some View {
    VStack {
      HStack(spacing: 0) {
        Text(title)
        Spacer()
        Button {
          addEmptySymbol()
        } label: {
          Image(systemName: "plus")
        }
      }
      .padding(.horizontal)

      List {
        ForEach(symbols, id: \.self) { symbol in
          VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
              if let index = index(symbol) {
                TextField(symbol, text: $symbols[index])
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
    }
  }
}

extension SymbolEditView {
  func index(_ symbol: String) -> Int? {
    if let index = symbols.firstIndex(of: symbol) {
      return index
    }
    return nil
  }

  func move(from source: IndexSet, to destination: Int) {
    symbols.move(fromOffsets: source, toOffset: destination)
  }

  func delete(from source: IndexSet) {
    symbols.remove(atOffsets: source)
  }

  func addEmptySymbol() {
    if let _ = symbols.first(where: { $0 == "" }) {
      ProgressHUD.showError("请先修改值为空的符号")
      return
    }
    symbols.append("")
  }
}
