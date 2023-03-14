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

  @State var rimeError: Error?
  @State var showError: Bool = false

  public var body: some View {
    GeometryReader { proxy in
      NavigationView {
        ZStack {
          Color.green.opacity(0.1).ignoresSafeArea()

          ScrollView {
            Section {
              Button {
                do {
                  try RimeEngine.syncAppGroupUserDataDirectory()
                  try rimeEngine.deploy()
                } catch {
                  rimeError = error
                  showError = true
                }
              } label: {
                Text("重新部署")
                  .frame(width: proxy.size.width - 40, height: 40)
                  .background(Color.white)
                  .foregroundColor(.primary)
                  .cornerRadius(10)
                  .shadow(radius: 3, x: 1, y: 1)
              }
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
                  Text("power by rime".uppercased())
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.secondary)
                }
              }
            }
            .padding(.top, 50)
          }
          .navigationTitle(
            "Hamster输入法"
          )
          .navigationBarTitleDisplayMode(.inline)
        }
      }
      .alert(isPresented: $showError) {
        if let error = rimeError {
          return Alert(title: Text("部署失败"), message: Text(error.localizedDescription))
        }
        return Alert(title: Text("部署失败"))
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
