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
  @ViewBuilder
  var cells: some View {
    CellView(
      width: cellWidth,
      height: cellHeight,
      imageName: "keyboard",
      featureName: "输入方案",
      navgationDestinationBuilder: {
        InputSchemaView()
      }
    )

    CellView(
      width: cellWidth,
      height: cellHeight,
      imageName: "paintpalette.fill",
      featureName: "配色选择",
      navgationDestinationBuilder: {
        ColorSchemaView()
      }
    )

    CellView(
      width: cellWidth,
      height: cellHeight,
      imageName: "network",
      featureName: "文件快传",
      navgationDestinationBuilder: {
        FileManagerView()
      }
    )

    CellView(
      width: cellWidth,
      height: cellHeight,
      imageName: "bubble.middle.bottom",
      featureName: "按键气泡",
      toggle: $appSetting.showKeyPressBubble
    )

    CellView(
      width: cellWidth,
      height: cellHeight,
      imageName: "character",
      featureName: "繁体中文",
      toggle: $appSetting.switchTraditionalChinese
    )

    CellView(
      width: cellWidth,
      height: cellHeight,
      imageName: "lasso",
      featureName: "空格滑动",
      toggle: $appSetting.slideBySapceButton
    )

    CellView(
      width: cellWidth,
      height: cellHeight,
      imageName: "info.circle",
      featureName: "关于",
      navgationDestinationBuilder: {
        AboutView()
      }
    )
  }

  var body: some View {
    Section {
      LazyVGrid(
        columns: [
          GridItem(.adaptive(minimum: 150))
        ],
        spacing: 20
      ) {
        cells
      }
      .padding(.horizontal)

    } header: {
      HStack {
        Text("设置")
          .font(.system(.body, design: .rounded))
          .fontWeight(.bold)
        Spacer()
      }
      .padding(.horizontal)
      .padding(.top, 20)
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
