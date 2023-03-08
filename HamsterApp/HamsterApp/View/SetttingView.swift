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

    var rimeSchema: [Schema] {
        return rimeEngine.getSchemas()
    }

    var currentSchema: Schema {
        if appSetting.preferences.rimeSelectSchema.isEmpty {
            return rimeEngine.status().currentSchema()
        }

        return rimeSchema
            .first(where: {
                $0.schemaId == appSetting.preferences.rimeSelectSchema
            }) ?? rimeEngine.status().currentSchema()
    }

    // TODO: 目前配置项少, 先在这里固定生成每个配置项页面
    @ViewBuilder
    var cells: some View {
        CellView(
            width: cellWidth,
            height: cellHeight,
            imageName: "keyboard",
            featureName: "方案选择",
            navgationDestination: InputSchemaView(
                schemas: rimeSchema,
                selectSchema: currentSchema
            )
        )

        CellView(
            width: cellWidth,
            height: cellHeight,
            imageName: "keyboard.macwindow",
            featureName: "按键气泡",
            toggle: $appSetting.preferences.showKeyPressBubble
        )

        CellView(
            width: cellWidth,
            height: cellHeight,
            imageName: "character",
            featureName: "繁体中文",
            toggle: $appSetting.preferences.switchTraditionalChinese
        )

        CellView(
            width: cellWidth,
            height: cellHeight,
            imageName: "space",
            featureName: "空格滑动",
            toggle: $appSetting.preferences.slideBySapceButton
        )
    }

    var body: some View {
        Section {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 150)),
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
