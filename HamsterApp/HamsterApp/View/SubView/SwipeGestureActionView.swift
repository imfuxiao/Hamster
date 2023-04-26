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

/// 全键盘滑动手势映射功能
@available(iOS 14, *)
struct SwipeGestureActionView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @State var editKey: String?
  @State var editValueType: ValueType = .String
  @State var editValue: String = ""
  @State var editValueSwipeFunction: FunctionalInstructions = .none
  @State var restState = false
  @State var showHamsteriCloud = false
  @State var fileData: Data = .init()

  var swipeGestureKeys: [String] {
    appSettings.keyboardSwipeGestureSymbol.keys.sorted()
  }

  let remark: String =
    """
    • ↑ 表示上滑 ↓ 表示下滑
    • ← 表示左滑 → 表示右滑
    • 点击显示项可进行编辑
        • 请先选选择滑动按键对应的类型.
        • 功能类型表示滑动会实现的功能, 比如中英切换等.
    """

  var header: some View {
    HStack {
      Text("按键滑动手势")
        .subViewTitleFont()
      Spacer()
    }
    .padding(.horizontal)
  }

  var content: some View {
    GeometryReader { _ in
      ScrollView {
        // 说明信息
        VStack {
          HStack {
            Text(remark)
              .font(.system(.callout, design: .rounded))
            Spacer()
          }
          .font(.system(.callout))
          .foregroundColor(.secondary)
        }
        .functionCell()

        ForEach(swipeGestureKeys, id: \.self) { key in
          Button {
            self.editValue = appSettings.keyboardSwipeGestureSymbol[key] ?? ""
            self.editValueType = self.editValue.hasPrefix("#") ? .Function : .String
            if self.editValueType == .Function, let function = FunctionalInstructions(rawValue: self.editValue) {
              self.editValueSwipeFunction = function
            }
            self.editKey = key
          } label: {
            VStack(alignment: .leading, spacing: 0) {
              HStack {
                Text(key)
                Spacer()
              }
              HStack {
                Text(appSettings.keyboardSwipeGestureSymbol[key] ?? "")
                  .font(.system(size: 14))
                Spacer()
              }
              .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .padding(.horizontal)
          }
          .buttonStyle(.plain)

          Divider().padding(.horizontal)
        }
      }
    }
  }

  @ViewBuilder
  var editorActionSheet: some View {
    BlackView(bgColor: .primary)
      .opacity(0.5)
      .onTapGesture {
        editKey = nil
      }

    EditActionValueView(
      actionKey: editKey!,
      editValueType: $editValueType,
      editValue: $editValue,
      editValueSlideFunction: $editValueSwipeFunction,
      dismiss: {
        editKey = nil
      }
    ) {
      var value = editValue.trimmingCharacters(in: .whitespacesAndNewlines)
      if editValueType == .Function {
        if editValueSwipeFunction != .none {
          value = editValueSwipeFunction.rawValue
        } else {
          value = ""
        }
      }
      appSettings.keyboardSwipeGestureSymbol[editKey!] = value
      do {
        fileData = try Plist(appSettings.keyboardSwipeGestureSymbol).toData()
      } catch {
        Logger.shared.log.error("dict to plist data error: \(error)")
      }
    }
    .transition(.move(edge: .bottom))
  }

  @ViewBuilder
  var iCloudView: some View {
    HamsteriCloudView(
      isShow: $showHamsteriCloud,
      document: HamsterDocument(fileName: "SwipeGestureActionBackup.plist", data: fileData),
      needExporter: true,
      contentType: .plist,
      importingCallback: { file in
        Logger.shared.log.debug("file.fileName: \(file.fileName)")
        let plist = Plist(data: file.data)
        appSettings.keyboardSwipeGestureSymbol = plist.strDict
        fileData = file.data
        showHamsteriCloud = false
      },
      exportingCallback: { result in
        if case .failure(let err) = result {
          Logger.shared.log.error("slide gesture export error: \(err.localizedDescription)")
        }
        showHamsteriCloud = false
      }
    )
    .transition(.move(edge: .bottom).animation(.easeInOut(duration: 1)))
  }

  var resetAlert: Alert {
    Alert(
      title: Text("是否恢复为默认值"),
      primaryButton: .default(Text("确定")) {
        appSettings.keyboardSwipeGestureSymbol = Plist.defaultAction
        do {
          fileData = try Plist(appSettings.keyboardSwipeGestureSymbol).toData()
        } catch {
          Logger.shared.log.error("dict to plist data error: \(error)")
        }
      },
      secondaryButton: .cancel(Text("取消")) {
        restState = false
      }
    )
  }

  var body: some View {
    GeometryReader { proxy in

      ZStack(alignment: .center) {
        Color.HamsterBackgroundColor.ignoresSafeArea()

        VStack {
          header

          VStack {
            HStack {
              Toggle(isOn: $appSettings.enableKeyboardSwipeGestureSymbol) {
                Text("是否启用")
                  .font(.system(.body, design: .rounded))
              }
            }
          }
          .functionCell()

          if appSettings.enableKeyboardSwipeGestureSymbol {
            VStack {
              HStack {
                Toggle(isOn: $appSettings.showKeyExtensionArea) {
                  Text("是否显示")
                    .font(.system(.body, design: .rounded))
                }
              }
            }
            .functionCell()

            content
          }
          Spacer()
        }

        // 单个Action编辑区
        if editKey != nil {
          editorActionSheet
        }

        // 导入按钮
        PlusButton {
          showHamsteriCloud.toggle()
        }
        .opacity(showHamsteriCloud ? 0 : 1)
        .offset(
          x: proxy.size.width / 2 - 60,
          y: proxy.size.height / 2 - 60
        )

        // iCloud
        if showHamsteriCloud {
          HamsteriCloudView(
            isShow: $showHamsteriCloud,
            document: HamsterDocument(fileName: "SwipeGestureActionBackup.plist", data: fileData),
            needExporter: true,
            contentType: .plist,
            importingCallback: { file in
              Logger.shared.log.debug("file.fileName: \(file.fileName)")
              let plist = Plist(data: file.data)
              appSettings.keyboardSwipeGestureSymbol = plist.strDict
              fileData = file.data
              showHamsteriCloud = false
            },
            exportingCallback: { result in
              if case .failure(let err) = result {
                Logger.shared.log.error("slide gesture export error: \(err.localizedDescription)")
              }
              showHamsteriCloud = false
            }
          )
          .transition(.move(edge: .bottom).animation(.easeInOut(duration: 1)))
        }
      }
      .navigationBarTitleDisplayMode(.inline)
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
        resetAlert
      }
      .onAppear {
        do {
          fileData = try Plist(appSettings.keyboardSwipeGestureSymbol).toData()
        } catch {
          Logger.shared.log.error("slideGestureMapping to data error: \(error.localizedDescription)")
        }
      }
    }
  }
}

/// 滑动动作编辑View
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
                  Text("\($0.rawValue)").tag($0)
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
    settings.keyboardSwipeGestureSymbol = defaultAction.strDict
    return settings
  }

  static var previews: some View {
    SwipeGestureActionView()
      .environmentObject(appSettings)
  }
}

extension String: Identifiable {
  public var id: Int {
    return hashValue
  }
}
