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

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Color.HamsterBackgroundColor.opacity(0.1).ignoresSafeArea()

        VStack {
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
          }

          SectionView("RIME") {
            LongButton(
              buttonText: "RIME重置",
              buttonWidth: proxy.size.width - 40
            ) {
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
            }
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
