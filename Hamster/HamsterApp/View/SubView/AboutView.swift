//
//  AboutView.swift
//  HamsterApp
//
//  Created by morse on 9/3/2023.
//

import SwiftUI

struct AboutView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @Environment(\.openURL) var openURL

  let openSourceSoftLists = """
    • https://github.com/rime/librime
    • https://github.com/KeyboardKit/KeyboardKit
    • https://github.com/SwiftyBeaver/SwiftyBeaver
    • https://github.com/vapor/vapor
  """

  var body: some View {
    GeometryReader { _ in
      ZStack {
        Color.HamsterBackgroundColor.ignoresSafeArea()

        ScrollView {
          HStack {
            Text("关于")
              .subViewTitleFont()

            Spacer()
          }
          .padding(.horizontal)

          SectionView("应用信息") {
            VStack {
              HStack {
                Text("版本号: \(appSettings.appVersion)")
                Spacer()
              }
              HStack {
                Text("RIME: \(appSettings.rimeVersion)")
                Spacer()
              }
            }
            .padding(.horizontal)
            .padding(.top, 10)
          }

          SectionView("使用开源库") {
            VStack {
              HStack {
                Text(openSourceSoftLists)
                  .scaleEffect(0.8)
                Spacer()
              }
            }
            .padding(.horizontal)
            .padding(.top, 10)
          }

          SectionView("许可") {
            VStack {
              HStack {
                Text("许可证: GPLv3")
                Spacer()
              }
              .contentShape(Rectangle())
              .onTapGesture {
                openURL(URL(string: "https://www.gnu.org/licenses/gpl-3.0.html")!)
              }
            }
            .padding(.horizontal)
            .padding(.top, 10)
          }

          SectionView("寻求帮助") {
            VStack {
              HStack {
                Text("个人能力有限, 目前软件还不完善, 给您造成困扰, 我感到万分抱歉. 您可以给我发邮件, 把您遇到的问题发给我.  如果您有能力动手改代码, 也欢迎您提交PR.")
                Spacer()
              }

              HStack {
                Text("邮箱:")
                Spacer()
              }
              HStack {
                Text("morse.hsiao@gmail.com")
                Spacer()
              }

              HStack {
                Text("项目地址:")
                Spacer()
              }
              HStack {
                Text("https://github.com/imfuxiao/Hamster")
                Spacer()
              }
            }
            .padding(.horizontal)
            .padding(.top, 10)
          }

          Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
  }
}
