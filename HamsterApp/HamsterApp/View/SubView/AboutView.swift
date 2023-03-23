//
//  AboutView.swift
//  HamsterApp
//
//  Created by morse on 9/3/2023.
//

import SwiftUI

struct AboutView: View {
  @EnvironmentObject
  var appSettings: HamsterAppSettings

  @EnvironmentObject
  var rimeEngine: RimeEngine

  @Environment(\.openURL)
  var openURL

  let infoDictionary = Bundle.main.infoDictionary ?? [:]

  var appVersion: String {
    infoDictionary["CFBundleShortVersionString"] as? String ?? ""
  }

  var rimeVersion: String {
    infoDictionary["rimeVersion"] as? String ?? ""
  }

  @State var isLoading = false
  @State var loadingText = ""
  @State var rimeError: Error?
  @State var restState = false

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Color.HamsterBackgroundColor.opacity(0.1).ignoresSafeArea()

        VStack {
          HStack {
            Text("关于")
              .font(.system(size: 30, weight: .black))

            Spacer()
          }
          .padding(.horizontal)

          SectionView("应用信息") {
            VStack {
              HStack {
                Text("版本号: \(appVersion)")
                Spacer()
              }
              HStack {
                Text("RIME: \(rimeVersion)")
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
              .contentShape(Rectangle(), eoFill: true)
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

          SectionView("RIME") {
            LongButton(
              buttonText: "RIME重置",
              buttonWidth: proxy.size.width - 40
            ) {
              restState = true
            }
          }
          .alert(isPresented: $restState) {
            Alert(
              title: Text("重置会删除个人上传方案, 恢复到原始安装状态, 确定重置?"),
              primaryButton: .destructive(Text("确定")) {
                loadingText = "RIME重置中, 请稍后."
                isLoading = true

                DispatchQueue.global(qos: .background).async {
                  var err: Error?
                  do {
                    try RimeEngine.initAppGroupUserDataDirectory(override: true)
                    rimeEngine.deploy()
                  } catch {
                    err = error
                    isLoading = false
                    return
                  }
                  DispatchQueue.main.async {
                    rimeError = err
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                      isLoading = false
                    }
                    appSettings.rimeNeedOverrideUserDataDirectory = true
                  }
                }

              },
              secondaryButton: .cancel(Text("取消"))
            )
          }

          Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)

        if isLoading {
          DotsLoadingView(text: loadingText)
        }
      }
    }
  }
}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
  }
}
