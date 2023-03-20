//
//  RowView.swift
//  HamsterApp
//
//  Created by morse on 5/3/2023.
//

import SwiftUI

struct SettingView: View {
  @EnvironmentObject
  var appSetting: HamsterAppSettings

  @EnvironmentObject
  var rimeEngine: RimeEngine

  var cellWidth: CGFloat
  var cellHeight: CGFloat

  // TODO: 目前配置项少, 先在这里固定生成每个配置项页面
  var cells: [CellView<AnyView>] {
    [
      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "keyboard",
        featureName: "输入方案",
        navgationDestinationBuilder: {
          AnyView(InputSchemaView())
        }
      ),

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "paintpalette.fill",
        featureName: "配色选择",
        navgationDestinationBuilder: {
          AnyView(ColorSchemaView())
        }
      ),

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "hand.tap",
        featureName: "键盘反馈",
        navgationDestinationBuilder: {
          AnyView(FeedbackView())
        }
      ),

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "network",
        featureName: "文件快传",
        navgationDestinationBuilder: {
          AnyView(FileManagerView())
        }
      ),

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "bubble.middle.bottom",
        featureName: "按键气泡",
        toggle: $appSetting.showKeyPressBubble
      ),

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "chevron.down.circle",
        featureName: "键盘收起键",
        toggle: $appSetting.showKeyboardDismissButton
      ),

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "character",
        featureName: "繁体中文",
        toggle: $appSetting.switchTraditionalChinese
      ),

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "lasso",
        featureName: "空格滑动",
        toggle: $appSetting.slideBySapceButton
      ),
      

      CellView(
        width: cellWidth,
        height: cellHeight,
        imageName: "info.circle",
        featureName: "关于",
        navgationDestinationBuilder: {
          AnyView(AboutView())
        }
      ),
    ]
  }

  var body: some View {
    SectionView("设置") {
      LazyVGrid(
        columns: [
          GridItem(.adaptive(minimum: 150)),
        ],
        spacing: 20
      ) {
        ForEach(0 ..< cells.count, id: \.self) {
          cells[$0]
        }
      }
      .padding(.horizontal)
    }
  }
}

struct RowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SettingView(cellWidth: 180, cellHeight: 100)
    }
    .background(Color.green.opacity(0.1))
    .environmentObject(HamsterAppSettings())
    .environmentObject(RimeEngine.shared)
  }
}
