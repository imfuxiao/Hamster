//
//  UpAndDownSlideInputSymbolView.swift
//  HamsterApp
//
//  Created by morse on 2023/3/23.
//

import Plist
import SwiftUI

enum ValueType: String, Equatable, CaseIterable, Identifiable {
  var id: Self {
    self
  }

  case Function = "功能"
  case String = "字符"
}

struct UpAndDownSlideInputSymbolView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @State var editKey: String?
  @State var editValueType: ValueType = .String
  @State var editValue: String = ""
  @State var editValueSlideFunction: FunctionalInstructions = .none
  @State var upAndDownSlideSymbols: [String: String] = [:]
  @State var restState = false

  var upAndDownSlideSymbolKeys: [String] {
    upAndDownSlideSymbols.keys.sorted()
  }

  let remark: String =
    """
    • ↑表示上划
    • ↓表示下划
    • 点击显示项可进行编辑
        • 请先选选择字符对应的类型.
        • 字符类型表示上下滑动时会输入的字符, 键盘皮肤也会显示同样字符;
        • 功能类型表示上下滑动会实现的功能, 比如中英切换等. 键盘皮肤会显示后面的说明文字;
    """

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      VStack {
        HStack {
          Text("上下滑动输入数字符号")
            .subViewTitleFont()
          Spacer()
        }
        .padding(.horizontal)

        VStack {
          HStack {
            Toggle(isOn: $appSettings.enableKeyboardUpAndDownSlideSymbol) {
              Text("是否启用")
                .font(.system(.body, design: .rounded))
            }
          }
          if appSettings.enableKeyboardUpAndDownSlideSymbol {
            HStack {
              Text(remark)
                .font(.system(.callout, design: .rounded))
              Spacer()
            }
            .font(.system(.callout))
            .foregroundColor(.secondary)
          }
        }
        .padding([.top, .bottom], 15)
        .padding(.horizontal)
        .background(Color.HamsterCellColor)
        .foregroundColor(Color.HamsterFontColor)
        .cornerRadius(8)
        .hamsterShadow()
        .padding(.horizontal)
        .padding(.bottom, 10)

        if appSettings.enableKeyboardUpAndDownSlideSymbol {
          VStack {
            HStack {
              Toggle(isOn: $appSettings.showKeyboardUpAndDownSlideSymbol) {
                Text("是否显示")
                  .font(.system(.body, design: .rounded))
              }
            }
          }
          .padding([.top, .bottom], 15)
          .padding(.horizontal)
          .background(Color.HamsterCellColor)
          .foregroundColor(Color.HamsterFontColor)
          .cornerRadius(8)
          .hamsterShadow()
          .padding(.horizontal)
          .padding(.bottom, 10)

          ScrollView {
            ForEach(upAndDownSlideSymbolKeys, id: \.self) { key in
              Button {
                self.editValue = upAndDownSlideSymbols[key] ?? ""
                self.editValueType = self.editValue.hasPrefix("#") ? .Function : .String
                if self.editValueType == .Function, let function = FunctionalInstructions(rawValue: self.editValue) {
                  self.editValueSlideFunction = function
                }
                self.editKey = key
              } label: {
                VStack(alignment: .leading, spacing: 0) {
                  HStack {
                    Text(key)
                    Spacer()
                  }
                  HStack {
                    Text(upAndDownSlideSymbols[key] ?? "")
                    Spacer()
                  }
                  .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .padding(.horizontal)
              }
              .buttonStyle(.plain)

              Divider()
                .padding(.horizontal)
            }
          }
          // end ScrollView
        }
        // end if

        Spacer()
      }
      // VStack End

      if editKey != nil {
        BlackView(bgColor: .primary)
          .opacity(0.5)
          .onTapGesture {
            editKey = nil
          }

        EditActionValueView(
          actionKey: editKey!,
          editValueType: $editValueType,
          editValue: $editValue,
          editValueSlideFunction: $editValueSlideFunction,
          dismiss: {
            editKey = nil
          }
        ) {
          var value = editValue.trimmingCharacters(in: .whitespacesAndNewlines)
          if editValueType == .Function {
            if editValueSlideFunction != .none {
              value = editValueSlideFunction.rawValue
            } else {
              value = ""
            }
          }
          upAndDownSlideSymbols[editKey!] = value
          appSettings.keyboardUpAndDownSlideSymbol = upAndDownSlideSymbols
        }
        .transition(.move(edge: .bottom))
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .animation(.linear, value: appSettings.enableKeyboardUpAndDownSlideSymbol)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          restState = true
        } label: {
          Text("恢复默认值")
        }
      }
    }
    .alert(isPresented: $restState) {
      Alert(
        title: Text("是否恢复为默认值"),
        primaryButton: .default(Text("确定")) {
          appSettings.keyboardUpAndDownSlideSymbol = Plist.defaultAction
          upAndDownSlideSymbols = appSettings.keyboardUpAndDownSlideSymbol
        },
        secondaryButton: .cancel(Text("取消")) {
          restState = false
        }
      )
    }
    .onAppear {
      upAndDownSlideSymbols = appSettings.keyboardUpAndDownSlideSymbol
    }
    // ZStack End
  }
}

struct BlackView: View {
  var bgColor: Color
  var body: some View {
    VStack {
      Spacer()
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    .background(bgColor)
    .edgesIgnoringSafeArea(.all)
  }
}

struct EditActionValueView: View {
  @Environment(\.colorScheme) var colorScheme

  let actionKey: String
  @Binding var editValueType: ValueType
  @Binding var editValue: String
  @Binding var editValueSlideFunction: FunctionalInstructions

  var dismiss: () -> Void
  var saveAction: () -> Void

  var body: some View {
    GeometryReader { proxy in
      VStack {
        Spacer()

        VStack {
          HStack {
            Text(actionKey)
              .font(.system(size: 18, weight: .bold))
            Spacer()
          }
          .padding([.leading, .trailing], 20)
          .padding(.top, 70)

          HStack {
            Text("符号表示类型")
            Spacer()
            Picker("类型", selection: $editValueType) {
              ForEach(ValueType.allCases) {
                Text($0.rawValue).tag($0)
              }
            }
          }
          .frame(height: 40)
          .padding(.horizontal)

          if editValueType == .String {
            TextField("键值", text: $editValue)
              .textFieldStyle(
                BorderTextFieldBackground(
                  systemImageString: "pencil",
                  height: 40
                ))
              .background(Color.HamsterCellColor)
              .padding(.horizontal)
          } else {
            HStack {
              Text("功能")
              Spacer()
              Picker("功能", selection: $editValueSlideFunction) {
                ForEach(FunctionalInstructions.allCases) {
                  Text("\($0.rawValue)\($0.text == "" ? "(不显示)" : ("(显示:" + $0.text + ")"))")
                    .tag($0)
                }
              }
            }
            .frame(height: 40)
            .padding(.horizontal)
          }

          Spacer()
        }
        .background(Color("BackgroundColor"))
        .overlay(
          VStack {
            HStack {
              Button {
                dismiss()
              } label: {
                Text("取消")
              }
              .padding(.leading, 20)
              .padding(.top, 30)
              .buttonStyle(.plain)

              Spacer()

              Button {
                saveAction()
                dismiss()
              } label: {
                Text("保存")
              }
              .padding(.trailing, 20)
              .padding(.top, 30)
              .buttonStyle(.plain)
            }

            Spacer()
          }
        )
      }
      .offset(y: proxy.size.height / 2)
      .animation(.interpolatingSpring(stiffness: 200, damping: 25))
      .edgesIgnoringSafeArea(.all)
    }
  }
}

struct UpAndDownSlideInputSymbolView_Previews: PreviewProvider {
  @PlistWrapper(path: Bundle.main.url(forResource: "DefaultAction", withExtension: "plist")!)
  static var defaultAction: Plist

  static var appSettings: HamsterAppSettings {
    let settings = HamsterAppSettings()
    settings.keyboardUpAndDownSlideSymbol = defaultAction.strDict
    return settings
  }

  static var previews: some View {
    UpAndDownSlideInputSymbolView()
      .environmentObject(appSettings)
  }
}

extension String: Identifiable {
  public var id: Int {
    return hashValue
  }
}
