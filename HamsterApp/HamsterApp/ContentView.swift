//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import SwiftUI

public struct ContentView: View {
  var appSetings = HamsterAppSettings()

  public init() {}

  public var body: some View {
    TabView {
      SettingView()
        .tabItem {
          Label("设置", systemImage: "gear.circle")
        }
      AboutView()
        .tabItem {
          Label("关于", systemImage: "info.circle.fill")
        }
    }
    .environmentObject(appSetings)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice("iPhone 14 Pro")
  }
}
