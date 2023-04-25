//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import SwiftUI

public struct ContentView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeEngine: RimeEngine
  @Environment(\.openURL) var openURL
  @State var rimeError: Error?
  @State var showError: Bool = false
  @State var isLoading: Bool = false
  @State var loadingText: String = ""
  @State var cells: [CellViewModel] = []
  @State var restState = false

  var cancel: [AnyCancellable] = []
  let cellDestinationRoute = CellDestinationRoute()

  init() {
//    let navView = UIView()
//
//    let label = UILabel()
//    label.text = "Text"
//    label.sizeToFit()
//    label.center = navView.center
//    label.textAlignment = NSTextAlignment.center
//
//    let image = UIImageView()
//    image.image = UIImage(named: "Hamster")
//    image.contentMode = .scaleAspectFit
//
//    navView.addSubview(label)
//    navView.addSubview(image)
  }

  // TODO: 体验功能暂未实现
//  @State var userExperienceState = true
//  @State var userExperienceText: String = ""
//  @State var responder = true

  public var body: some View {
    GeometryReader { proxy in
      NavigationView {
        ZStack {
          Color.HamsterBackgroundColor.ignoresSafeArea()

          ScrollView {
            // Rime 区域 Begin
            SectionView("RIME") {
              LongButton(
                buttonText: "重新部署",
                buttonWidth: proxy.size.width - 40
              ) {
                loadingText = "正在部署, 请稍候."
                isLoading = true
                appSettings.rimeNeedOverrideUserDataDirectory = true
                DispatchQueue.global().async {
                  rimeEngine.deploy()
                  let schemas = rimeEngine.getSchemas()
                  let userSelectInputSchema = schemas.first(where: { $0.schemaId == appSettings.rimeInputSchema })
                  DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if userSelectInputSchema == nil {
                      appSettings.rimeInputSchema = schemas.first?.schemaId ?? ""
                    }
                    rimeEngine.shutdownRime()
                    isLoading = false
                    Logger.shared.log.debug("DispatchQueue.main.async end...")
                  }
                }
              }

              LongButton(
                buttonText: "RIME重置",
                buttonWidth: proxy.size.width - 40
              ) {
                restState = true
              }
            }
            .alert(isPresented: $showError) {
              if let error = rimeError {
                return Alert(title: Text("部署失败"), message: Text(error.localizedDescription))
              }
              return Alert(title: Text("部署失败"))
            }
            .alert(isPresented: $restState) {
              Alert(
                title: Text("重置会删除个人上传方案, 恢复到原始安装状态, 确定重置?"),
                primaryButton: .destructive(Text("确定")) {
                  loadingText = "RIME重置中, 请稍候."
                  isLoading = true
                  DispatchQueue.global().async {
                    do {
                      try RimeEngine.initAppGroupSharedSupportDirectory(override: true)
                      try RimeEngine.initAppGroupUserDataDirectory(override: true)
                    } catch {
                      rimeError = error
                      isLoading = false
                      return
                    }

                    rimeEngine.deploy()
                    let schemas = rimeEngine.getSchemas()
                    let userSelectInputSchema = schemas.first(where: { $0.schemaId == appSettings.rimeInputSchema })
                    rimeEngine.shutdownRime()

                    DispatchQueue.main.async {
                      appSettings.rimeNeedOverrideUserDataDirectory = true
                      if userSelectInputSchema == nil {
                        appSettings.rimeInputSchema = schemas.first?.schemaId ?? ""
                      }
                      isLoading = false
                      Logger.shared.log.debug("DispatchQueue.main.async end...")
                    }
                  }
                },
                secondaryButton: .cancel(Text("取消"))
              )
            }
            // Rime 区域 end

            // 中间设置区域 Begin
            SettingView(
              cells: cells,
              cellDestinationRoute: cellDestinationRoute
            )
            // 中间设置区域 End

            // 底部begin
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
            // 底部end
          }

          // ScrollView

          if isLoading {
            DotsLoadingView(text: loadingText)
          }

          if !appSettings.isKeyboardEnabled {
            VStack {
              Spacer()

              HStack {
                Text("您还未启用仓输入法, 点击跳转开启.")
                  .font(.system(size: 20, weight: .black))
                  .foregroundColor(Color.primary)
              }
              .frame(width: proxy.size.width, height: 80)
              .background(Color("dots"))
              .onTapGesture {
                // 点击跳转设置
                openURL(URL(string: AppConstants.addKeyboardPath)!)
                print(UIApplication.openSettingsURLString)
              }
            }
            .ignoresSafeArea()
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("仓输入法"))
        .toolbar {
          ToolbarItem(placement: .principal) {
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
        }
        // ZStack
      }
      .navigationViewStyle(.stack)
      // Navigation
    }
    .onAppear {
      cells = createCells(cellWidth: 160, cellHeight: 100, appSettings: appSettings)
    }
    // GeometryReader End
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice("iPhone 13 mini")
      .environmentObject(HamsterAppSettings())
      .environmentObject(RimeEngine())
  }
}
