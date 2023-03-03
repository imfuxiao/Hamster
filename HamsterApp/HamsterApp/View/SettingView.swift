//
//  SwiftUIView.swift
//
//
//  Created by morse on 2/2/2023.
//

import SwiftUI

struct SettingView: View {
  @EnvironmentObject
  var appSettings: HamsterAppSettings

  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        SectionView(title: "界面调整", description: "此处调节所有键盘界面配置, 可自定义键盘的用户界面, 比如高度, 炫彩, 字体和皮肤等") {
          VStack {
            Text("...")
          }
        }
        SectionView(title: "功能定制", description: "此处自定义键盘的功能, 如简繁切换, 键盘反馈设置等") {
          KeyboardFunctionSettingView()
        }
        Spacer()
      }
      .padding(.top, 20)
      .listStyle(.plain)
      .navigationTitle(
        Text("偏好设置")
      )
    }
  }
}

struct SectionView<Content: View>: View {
  var title: String
  var description: String
  var content: () -> Content
  var body: some View {
    NavigationLink(destination: {
      content()
    }, label: {
      VStack(alignment: .leading) {
        Text(title)
          .font(.system(.title3, design: .rounded))
          .foregroundColor(Color("Color/settingTitle"))
          .bold()
          .padding(.bottom, 5)

        Text(description)
          .font(.system(.callout, design: .rounded))
          .foregroundColor(Color(.systemGray2))
          .multilineTextAlignment(.leading)
      }
      .padding(10)
      .frame(minWidth: 0, maxWidth: .infinity)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(Color.yellow, lineWidth: 1)
      )
      .padding(.horizontal)
    })
  }
}

struct SettingView_Previews: PreviewProvider {
  static var previews: some View {
    SettingView()
      .environmentObject(HamsterAppSettings())
  }
}
