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
                  DispatchQueue.main.async(qos: .background) {
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
          .navigationBarTitleDisplayMode(.inline)
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
          // ZStack End
        }
        .navigationViewStyle(.automatic)
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
      .onAppear {
        cells = createCells(cellWidth: 160, cellHeight: 100, appSettings: appSettings)
      }
      // ZStack end
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
