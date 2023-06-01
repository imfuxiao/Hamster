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

  @State var tags = ["成对上屏", "光标居中", "返回主键盘", "其他"]
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

        if selectTag == 0 {
          SymbolEditView(symbols: $appSettings.pairsOfSymbols, title: "符号成对上屏")
        }

        if selectTag == 1 {
          SymbolEditView(symbols: $appSettings.cursorBackOfSymbols, title: "光标可以居中符号")
        }

        if selectTag == 2 {
          SymbolEditView(symbols: $appSettings.returnToPrimaryKeyboardOfSymbols, title: "返回主键盘的符号")
        }

        if selectTag == 3 {
          VStack(spacing: 0) {
            LongButton(
              buttonText: "符号键盘 - 常用符号重置"
            ) {
              SymbolCategory.frequentSymbolProvider.rest()
              ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
            }
            .padding(.all)
          }

          VStack(spacing: 0) {
            LongButton(
              buttonText: "成对上屏符号重置"
            ) {
              appSettings.pairsOfSymbols = HamsterAppSettingKeys.defaultPairsOfSymbols
              ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
            }
            .padding(.all)
          }

          VStack(spacing: 0) {
            LongButton(
              buttonText: "光标居中符号重置"
            ) {
              appSettings.cursorBackOfSymbols = HamsterAppSettingKeys.defaultCursorBackOfSymbols
              ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
            }
            .padding(.all)
          }

          VStack(spacing: 0) {
            LongButton(
              buttonText: "返回主键盘符号重置"
            ) {
              appSettings.returnToPrimaryKeyboardOfSymbols =
                HamsterAppSettingKeys.defaultReturnToPrimaryKeyboardOfSymbols
              ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
            }
            .padding(.all)
          }
        }

        Spacer()
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
  init(
    symbols: Binding<[String]>, title: String, moveDisabled: Bool = true, deleteDisabled: Bool = false
  ) {
    self._symbols = symbols
    self.title = title
    self.moveDisabled = moveDisabled
    self.deleteDisabled = deleteDisabled
  }

  @Binding var symbols: [String]
  @State var selectIndex: Int = 0
  var title: String
  let moveDisabled: Bool
  let deleteDisabled: Bool
  @State var moveState = false

  var itemsView: some DynamicViewContent {
    ForEach(0 ..< symbols.count, id: \.self) { idx in
      VStack(spacing: 0) {
        Spacer()
        HStack(spacing: 0) {
          TextField("", text: Binding(get: { symbols[idx] }, set: { symbols[idx] = $0 }), onEditingChanged: { _ in selectIndex = idx })
            .textFieldStyle(.roundedBorder)
            .frame(width: 80)
            .multilineTextAlignment(.center)
          Spacer()
          if !moveDisabled {
            if #available(iOS 15, *) {
              Image(systemName: "line.3.horizontal")
            } else {
              Image(systemName: "pencil")
            }
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        Spacer()
      }
      .moveDisabled(moveDisabled)
      .deleteDisabled(deleteDisabled)
//      .hideListRowSeparator() // 隐藏行线在onMove中有bug
      .listRowBackground(Color.HamsterBackgroundColor)
      .tag(idx)
    }
    .onMove(perform: move)
    .onDelete(perform: delete)
  }

  var body: some View {
    VStack {
      HStack(spacing: 0) {
        Text(title)
          .font(.system(.caption))

        Spacer()

        Button {
          addEmptySymbol()
        } label: {
          Image(systemName: "plus")
            .contentShape(Rectangle())
        }
      }
      .padding(.horizontal)

      ScrollViewReader { scrollProxy in
        List {
          itemsView
        }
        .listStyle(.plain)
        .onChange(of: selectIndex) { _ in
          scrollProxy.scrollTo(selectIndex, anchor: .center)
        }
      }
    }
  }
}

extension SymbolEditView {
  func move(from source: IndexSet, to destination: Int) {
    withAnimation {
      symbols.move(fromOffsets: source, toOffset: destination)
    }
  }

  func delete(from source: IndexSet) {
    withAnimation {
      symbols.remove(atOffsets: source)
    }
  }

  func addEmptySymbol() {
    if let _ = symbols.first(where: { $0 == "" }) {
      ProgressHUD.showError("请先修改值为空的符号")
      return
    }
    symbols.append("")
    selectIndex = symbols.count - 1
  }
}
