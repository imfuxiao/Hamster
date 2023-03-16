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

  @State var isLoading = false
  @State var rimeError: Error?

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Color.HamsterBackgroundColor.opacity(0.1).ignoresSafeArea()

        VStack {
          Button {
            // TODO: 缺少日志显示
            isLoading = true
            DispatchQueue.global(qos: .background).async {
              var err: Error?
              do {
                try RimeEngine.initAppGroupUserDataDirectory(override: true)
                rimeEngine.deploy()
              } catch {
                err = error
              }
              DispatchQueue.main.async {
                rimeError = err
                isLoading = false
                appSettings.rimeNeedOverrideUserDataDirectory = true
              }
            }
          } label: {
            Text("RIME重置")
              .frame(width: proxy.size.width - 40, height: 40)
              .background(Color.HamsterCellColor)
              .foregroundColor(Color.HamsterFontColor)
              .cornerRadius(10)
              .hamsterShadow()
          }
          .disabled(isLoading)
          .buttonStyle(.plain)

          Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)

        if isLoading {
          LoaderView(scaleSize: 3)
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
