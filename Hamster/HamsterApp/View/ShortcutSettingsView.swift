//
//  ShortcutSettingsView.swift
//  HamsterApp
//
//  Created by morse on 4/5/2023.
//

import Combine
import Foundation
import ProgressHUD
import SwiftUI

/// 首屏 快捷设置页
struct ShortcutSettingsView: View {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self._appSettings = ObservedObject(wrappedValue: appSettings)
    self._rimeContext = ObservedObject(wrappedValue: rimeContext)
    self.rimeViewModel = RIMEViewModel(rimeContext: rimeContext, appSettings: appSettings)
    self.cells = createCells(cellWidth: 160, cellHeight: 100, appSettings: self._appSettings)
  }

  @ObservedObject
  var appSettings: HamsterAppSettings

  @ObservedObject
  var rimeContext: RimeContext

  let rimeViewModel: RIMEViewModel
  let cells: [CellViewModel]

  @Environment(\.openURL) var openURL

  @State var rimeError: Error?
  @State var showDeploymentAlert: Bool = false
  @State var isLoading: Bool = false
  @State var loadingText: String = ""
  @State var restState = false

  let cellDestinationRoute = CellDestinationRoute()

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

  public var body: some View {
    VStack(alignment: .center, spacing: 0) {
      GeometryReader { proxy in
        ScrollView {
          // 启用仓输入法
          if !self.appSettings.isKeyboardEnabled {
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
            .frame(width: proxy.size.width - 40)
          }
          .alert(isPresented: self.$showDeploymentAlert) { Alert(title: Text("部署失败"), message: Text(self.rimeError?.localizedDescription ?? "")) }

          SettingView(
            cells: self.cells,
            cellDestinationRoute: self.cellDestinationRoute
          )

          self.footView
        }
      }
    }
    .background(Color.HamsterBackgroundColor.ignoresSafeArea())
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

struct ShortcutSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    ShortcutSettingsView(appSettings: HamsterAppSettings(), rimeContext: RimeContext())
      .previewDevice("iPhone 13 mini")
  }
}
