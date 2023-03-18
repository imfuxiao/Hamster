//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import SwiftUI

public struct ContentView: View {
  @EnvironmentObject var rimeEngine: RimeEngine
  @EnvironmentObject var appSettings: HamsterAppSettings

  @State var rimeError: Error?
  @State var showError: Bool = false
  @State var isLoading: Bool = false
  var cancel: [AnyCancellable] = []

  // TODO: 体验功能暂未实现
  @State var userExperienceState = true
  @State var userExperienceText: String = ""
  @State var responder = true

  public var body: some View {
    ZStack {
      GeometryReader { proxy in
        NavigationView {
          ZStack {
            Color.HamsterBackgroundColor.opacity(0.1).ignoresSafeArea()

            ScrollView {
              Section {
                Button {
                  // TODO: 缺少日志显示
                  isLoading = true
                  DispatchQueue.global(qos: .background).async {
                    rimeEngine.deploy()
                    DispatchQueue.main.async {
                      appSettings.rimeNeedOverrideUserDataDirectory = true
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isLoading = false
                      }
                    }
                  }
                } label: {
                  Text("重新部署")
                    .frame(width: proxy.size.width - 40, height: 40)
                    .background(Color.HamsterCellColor)
                    .foregroundColor(Color.HamsterFontColor)
                    .cornerRadius(10)
                    .hamsterShadow()
                }
                .disabled(isLoading)
                .buttonStyle(.plain)

              } header: {
                HStack {
                  Text("RIME")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                  Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
              }

              SettingView(cellWidth: proxy.size.width / 2 - 40, cellHeight: 100)

              Spacer()

              VStack {
                VStack {
                  HStack {
                    Text("powered by rime".uppercased())
                      .font(.system(.footnote, design: .rounded))
                      .foregroundColor(.secondary)
                  }
                }
              }
              .padding(.top, 50)
              .padding(.bottom, 50)
            }
            .navigationTitle(
              "Hamster输入法"
            )
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showError) {
              if let error = rimeError {
                return Alert(title: Text("部署失败"), message: Text(error.localizedDescription))
              }
              return Alert(title: Text("部署失败"))
            }

            if isLoading {
              ZStack {
                Color.secondary.opacity(0.3).ignoresSafeArea(.all)
                DotsActivityView(color: .green.opacity(0.8))
              }
            }
          }
        }
      }

      if !userExperienceState {
        VStack(spacing: 0) {
          Spacer()
          Button {
            userExperienceState = true
          } label: {
            Text("点击体验输入法")
              .font(.system(.body))
              .fontWeight(.bold)
              .frame(minWidth: 0, maxWidth: .infinity)
              .frame(height: 50)
              .foregroundColor(Color.primary)
              .background(Color.HamsterBackgroundColor.opacity(0.6))
          }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .ignoresSafeArea(.all)
      }

      if !userExperienceState {
        VStack {
          Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)
        .background(Color.black.opacity(0.1))
        .ignoresSafeArea(.all)

        VStack {
          Spacer()
          HStack {
            TextField("输入", text: $userExperienceText)
              .textFieldStyle(.plain)
              .background(Color.secondary.opacity(0.8))
              .frame(minWidth: 0, maxWidth: .infinity)
              .frame(height: 100)
              .cornerRadius(30)
          }
          .padding(.horizontal)
          .frame(minWidth: 0, maxWidth: .infinity)
          .frame(height: 60)
          .background(Color.primary.opacity(0.8))
        }
        .transition(.move(edge: .bottom))
        .ignoresSafeArea()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice("iPhone 13 mini")
      .environmentObject(HamsterAppSettings())
      .environmentObject(RimeEngine.shared)
  }
}

extension View {
  func hamsterShadow() -> some View {
    return shadow(color: Color.HamsterShadowColor, radius: 2)
  }
}
