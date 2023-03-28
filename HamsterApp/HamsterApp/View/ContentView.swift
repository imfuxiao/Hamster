//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import SwiftUI

public struct ContentView: View {
  var appSettings = HamsterAppSettings.shared
  var rimeEngine = RimeEngine.shared

  @Environment(\.openURL) var openURL

  @State var rimeError: Error?
  @State var showError: Bool = false
  @State var isLoading: Bool = false
  @State var loadingText: String = ""
  var cancel: [AnyCancellable] = []

  let cellDestinationRoute = CellDestinationRoute()
  var cells: [CellViewModel] = createCells(cellWidth: 160, cellHeight: 100)

  // TODO: 体验功能暂未实现
//  @State var userExperienceState = true
//  @State var userExperienceText: String = ""
//  @State var responder = true

  public var body: some View {
    GeometryReader { proxy in
      ZStack {
        NavigationView {
          ZStack {
            Color
              .HamsterBackgroundColor
              .ignoresSafeArea()

            ScrollView {
              // RIME区域
              SectionView("RIME") {
                LongButton(
                  buttonText: "重新部署",
                  buttonWidth: proxy.size.width - 40
                ) {
                  loadingText = "正在部署, 请稍后."
                  isLoading = true
                  DispatchQueue.main.async {
                    rimeEngine.deploy()
                    appSettings.rimeNeedOverrideUserDataDirectory = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                      isLoading = false
                    }
                  }
                }
              }

              SettingView(
                cells: cells,
                cellDestinationRoute: cellDestinationRoute
              )

              Spacer()

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
            .alert(isPresented: $showError) {
              if let error = rimeError {
                return Alert(title: Text("部署失败"), message: Text(error.localizedDescription))
              }
              return Alert(title: Text("部署失败"))
            }

            if isLoading {
              DotsLoadingView(text: loadingText)
            }
          }
          .navigationTitle(Text("仓输入法"))
          .toolbar {
            ToolbarItem(placement: .principal) {
              VStack {
                HStack{
                  
                }
              }
            }
          }
          // ZStack End
        }
        .navigationViewStyle(.stack)
        // Navigation End

        if !appSettings.isKeyboardEnabled {
          VStack {
            Spacer()

            HStack {
              Text("您还未启用仓输入法, 点击跳转开启.")
                .font(.system(size: 20, weight: .bold))
            }
            .frame(width: proxy.size.width, height: 80)
            .background(Color("dots"))
            .foregroundColor(.white)
            .onTapGesture {
              // 点击跳转设置
              openURL(URL(string: AppConstants.addKeyboardPath)!)
            }
          }
          .ignoresSafeArea()
        }
        // TODO: 点击体验输入法(待开发)
      }
      // ZStack end
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice("iPhone 13 mini")
      .environmentObject(HamsterAppSettings.shared)
      .environmentObject(RimeEngine.shared)
  }
}

extension View {
  func hamsterShadow() -> some View {
    return shadow(color: Color.HamsterShadowColor, radius: 1)
  }
}
