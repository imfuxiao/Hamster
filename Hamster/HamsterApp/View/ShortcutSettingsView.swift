//
//  ShortcutSettingsView.swift
//  HamsterApp
//
//  Created by morse on 4/5/2023.
//

import Combine
import Foundation
import KeyboardKit
import ProgressHUD
import SwiftUI

/// 首屏 快捷设置页
struct ShortcutSettingsView: View {
  init(rimeViewModel: RIMEViewModel, cells: [CellViewModel]) {
    Logger.shared.log.debug("ShortcutSettingsView init")
    self.rimeViewModel = rimeViewModel
    self.cells = cells
  }

  let rimeViewModel: RIMEViewModel
  let cells: [CellViewModel]

  @Environment(\.openURL) var openURL
  @StateObject var keybaordState = KeyboardEnabledState(bundleId: "dev.fuxiao.app.Hamster.*")
  @State var rimeError: Error?
  @State var showDeploymentAlert: Bool = false
  @State var isLoading: Bool = false
  @State var loadingText: String = ""
  @State var restState = false

  var footView: some View {
    VStack {
      VStack {
        HStack {
          Text("powered by 中州韻輸入法引擎(rime)".uppercased())
            .font(.system(.footnote, design: .rounded))
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.top, 50)
    .padding(.bottom, 50)
  }

  var enableHamsterView: some View {
    VStack {
      Spacer()
      HStack {
        Text("您还未启用仓输入法，点击跳转开启。(开启完全访问权限可以保存自造词词库)")
          .font(.system(size: 20, weight: .black))
          .foregroundColor(Color.primary)
      }
      .frame(height: 80)
      .frame(minWidth: 0, maxWidth: .infinity)
      .background(Color("dots"))
      .onTapGesture {
        // 点击跳转设置
        self.openURL(URL(string: AppConstants.addKeyboardPath)!)
        print(UIApplication.openSettingsURLString)
      }
    }
  }

  var toolbarView: some View {
    VStack {
      HStack {
        Image("Hamster")
          .resizable()
          .scaledToFill()
          .frame(width: 25, height: 25)
          .padding(.all, 5)
          .background(
            RoundedRectangle(cornerRadius: 5)
              .stroke(Color.gray.opacity(0.5), lineWidth: 1)
          )
        Text("仓输入法")

        Spacer()
      }
    }
  }

  var settingView: some View {
    SectionView("设置") {
      LazyVGrid(
        columns: [
          GridItem(.adaptive(minimum: 160)),
        ],
        alignment: .center,
        spacing: 20
      ) {
        ForEach(self.cells) {
          CellView(cellViewModel: $0)
        }
      }
      .padding(.horizontal)
    }
  }

  public var body: some View {
    VStack(alignment: .center, spacing: 0) {
      GeometryReader { _ in
        ScrollView {
          // 启用仓输入法
          if !keybaordState.isKeyboardEnabled {
            self.enableHamsterView
          }

          SectionView("RIME") {
            LongButton(
              buttonText: "重新部署"
            ) {
              DispatchQueue.global().async {
                let handled = !self.rimeViewModel.deployment()
                DispatchQueue.main.async {
                  self.showDeploymentAlert = handled
                }
              }
            }
            .padding(.horizontal, 30)
          }
          .alert(isPresented: self.$showDeploymentAlert) { Alert(title: Text("部署失败"), message: Text(self.rimeError?.localizedDescription ?? "")) }

          // 设置 Cell 单元格
          settingView

          self.footView
        }
      }
    }
    .background(Color.HamsterBackgroundColor.ignoresSafeArea())
  }
}

extension ShortcutSettingsView {
  /// cell创建
  static func createCells(cellWidth: CGFloat, cellHeight: CGFloat, appSettings: HamsterAppSettings) -> [CellViewModel] {
    [
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "输入方案",
        imageName: "keyboard",
        destinationType: .inputSchema
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "配色选择",
        imageName: "paintpalette",
        destinationType: .colorSchema
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "键盘反馈",
        imageName: "hand.tap",
        destinationType: .feedback
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "输入方案上传",
        imageName: "network",
        destinationType: .fileManager
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "文件编辑",
        imageName: "creditcard",
        destinationType: .fileEditor
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "按键气泡",
        imageName: "bubble.middle.bottom",
        destinationType: .none,
        toggleValue: appSettings.showKeyPressBubble,
        toggleDidSet: { appSettings.showKeyPressBubble = $0 }
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "键盘收起键",
        imageName: "chevron.down.circle",
        destinationType: .none,
        toggleValue: appSettings.showKeyboardDismissButton,
        toggleDidSet: { appSettings.showKeyboardDismissButton = $0 }
      ),
      //    CellViewModel(
      //      cellWidth: cellWidth,
      //      cellHeight: cellHeight,
      //      cellName: "繁体中文",
      //      imageName: "character",
      //      destinationType: .none,
      //      toggleValue: appSettings.switchTraditionalChinese,
      //      toggleDidSet: { value in
      //        appSettings.switchTraditionalChinese = value
      //      }
      //    ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "空格滑动",
        imageName: "lasso",
        destinationType: .none,
        toggleValue: appSettings.enableSpaceSliding,
        toggleDidSet: { appSettings.enableSpaceSliding = $0 }
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "数字九宫格",
        imageName: "number.square",
        destinationType: .numberNineGridSetting
//        toggleValue: appSettings.enableNumberNineGrid,
//        toggleDidSet: { appSettings.enableNumberNineGrid = $0 }
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "输入功能调整",
        imageName: "gear",
        destinationType: .inputKeyFunction
      ),
      CellViewModel(
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        cellName: "按键滑动手势",
        imageName: "arrow.up.arrow.down",
        destinationType: .swipeGestureMapping
      ),
      //    CellViewModel(
      //      cellWidth: cellWidth,
      //      cellHeight: cellHeight,
      //      cellName: "关于",
      //      imageName: "info.circle",
      //      destinationType: .about
      //    ),
    ]
  }
}

struct HamsterNavigationBarView: View {
  var body: some View {
    VStack {
      HStack {
        Image("Hamster")
          .resizable()
          .scaledToFill()
          .frame(width: 25, height: 25)
          .padding(.all, 5)
          .background(
            RoundedRectangle(cornerRadius: 5)
              .stroke(Color.gray, lineWidth: 1)
          )
        Text("仓输入法")

        Spacer()
      }
    }
  }
}

// struct ShortcutSettingsView_Previews: PreviewProvider {
//  static var previews: some View {
//    ShortcutSettingsView(
//      appSettings: HamsterAppSettings(),
//      rimeContext: RimeContext()
//    )
//    .previewDevice("iPhone 13 mini")
//  }
// }
