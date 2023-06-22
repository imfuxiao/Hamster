//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import SwiftUI

struct ContentView: View {
  init() {
    Logger.shared.log.debug("ContentView init")
    // fix ScrollView 会超出Tabbar
    if #available(iOS 15, *) {
      UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance(idiom: .unspecified)
    }
  }

  @EnvironmentObject
  var appSettings: HamsterAppSettings

  @EnvironmentObject
  var rimeContext: RimeContext

  var toolbarView: some View {
    VStack(alignment: .center, spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        Image("Hamster")
          .resizable()
          .scaledToFill()
          .frame(width: 30, height: 30)
          .padding(.all, 5)
          .background(
            RoundedRectangle(cornerRadius: 5)
              .stroke(Color.gray.opacity(0.5), lineWidth: 1)
          )
        Text("仓输入法")
          .padding(.leading, 15)

        Spacer()
      }
    }
  }

  var body: some View {
    TabView {
      ShortcutSettingsView(
        rimeViewModel: RIMEViewModel(rimeContext: rimeContext, appSettings: appSettings),
        cells: ShortcutSettingsView.createCells(cellWidth: 160, cellHeight: 100, appSettings: appSettings)
      )
      .tabItem {
        VStack {
          Image(systemName: "house.fill")
          Text("快捷设置")
        }
      }
      .tag(0)

      AdvancedSettingsView()
        .tabItem {
          Image(systemName: "gear")
          Text("其他设置")
        }
        .tag(1)
    }
    .tabViewStyle(.automatic)
  }
}

struct Navigation<Content: View>: View {
  @ViewBuilder var content: () -> Content

  var body: some View {
    if #available(iOS 16, *) {
      NavigationStack {
        content()
      }
    } else {
      NavigationView {
        content()
      }
      .navigationViewStyle(.stack)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice("iPhone 13 mini")
      .environmentObject(HamsterAppSettings.shared)
      .environmentObject(RimeContext.shared)
  }
}
