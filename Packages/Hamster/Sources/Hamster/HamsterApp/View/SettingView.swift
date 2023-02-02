//
//  SwiftUIView.swift
//
//
//  Created by morse on 2/2/2023.
//

import SwiftUI

struct SettingView: View {
  var body: some View {
    NavigationView {
      List {
        SettingItemView(
          content: {
            Text("界面调整")
          }, label:
          SettingItemLableView(
            title: "界面调整", description: "调整键盘外观. 如字体等"
          )
        )

        SettingItemView(
          content: {
            FundtionSettingView()
          }, label:
          SettingItemLableView(
            title: "功能定制", description: "键盘功能模块定制: 如简繁转换, 按键反馈xxxxxxxxxxxxxx等"
          )
        )
      }
      .navigationTitle("设置")
    }
  }
}

struct FundtionSettingView: View {
  @EnvironmentObject
  var appSettings: HamsterAppSettings

  var body: some View {
    List {
      Toggle("繁体输出", isOn: $appSettings.preferences.isTraditionalChinese)
      Toggle("空格滑动", isOn: $appSettings.preferences.useSpaceSlide)
    }
    .navigationTitle("功能定制")
  }
}

struct SettingItemLableView: View {
  let title: String
  let description: String

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.system(.headline, design: .rounded))
      Text(description)
        .font(.system(.footnote, design: .rounded))
        .foregroundColor(.gray)
    }
    .padding(2)
  }
}

struct SettingItemView<ContentView: View, LabelView: View>: View {
  typealias ContentViewBuilder = () -> ContentView

  @ViewBuilder var content: ContentViewBuilder
  var label: LabelView

  init(@ViewBuilder content: @escaping ContentViewBuilder, label: LabelView) {
    self.content = content
    self.label = label
  }

  var body: some View {
    NavigationLink {
      content()
    } label: {
      label
    }
  }
}

struct SettingView_Previews: PreviewProvider {
  static var previews: some View {
    SettingView()
  }
}
