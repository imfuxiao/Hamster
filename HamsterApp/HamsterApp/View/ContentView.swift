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
  
  var resetAlert: Alert {
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
            DispatchQueue.main.async {
              rimeError = error
              isLoading = false
            }
            return
          }
          resetInputSchema()
        }
      },
      secondaryButton: .cancel(Text("取消"))
    )
  }
  
  var deployAlert: Alert {
    if let error = rimeError {
      return Alert(title: Text("部署失败"), message: Text(error.localizedDescription))
    }
    return Alert(title: Text("部署失败"))
  }
  
  // 重置输入方案相关值
  private func resetInputSchema() {
    let deployHandled = rimeEngine.deploy()
    Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")
    DispatchQueue.main.async {
      let resetHandled = appSettings.resetRimeParameter(rimeEngine)
      Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")
      isLoading = false
    }
  }
  
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
    GeometryReader { proxy in
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
    GeometryReader { proxy in
      NavigationView {
        ZStack {
          Color.HamsterBackgroundColor.ignoresSafeArea()
          ScrollView {
            SectionView("RIME") {
              LongButton(
                buttonText: "重新部署",
                buttonWidth: proxy.size.width - 40
              ) {
                loadingText = "正在部署, 请稍候."
                isLoading = true
                DispatchQueue.global().async {
                  resetInputSchema()
                }
              }
              
              LongButton(
                buttonText: "RIME重置",
                buttonWidth: proxy.size.width - 40
              ) {
                restState = true
              }
            }
            .alert(isPresented: $showError) { deployAlert }
            .alert(isPresented: $restState) { resetAlert }
            
            SettingView(
              cells: cells,
              cellDestinationRoute: cellDestinationRoute
            )
            
            footView
          }
          
          if !appSettings.isKeyboardEnabled {
            enableHamsterView
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("仓输入法"))
        .toolbar { ToolbarItem(placement: .principal) { toolbarView } }
        .hud(isShow: $isLoading, message: $loadingText)
      }
      .navigationViewStyle(.stack)
      .onAppear {
        cells = createCells(cellWidth: 150, cellHeight: 100, appSettings: appSettings)
      }
    }
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
