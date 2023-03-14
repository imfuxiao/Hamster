//
//  HamsterApp.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import SwiftUI

@main
struct HamsterApp: App {
  var appSetings = HamsterAppSettings()
  var rimeEngine = RimeEngine.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(appSetings)
        .environmentObject(rimeEngine)
    }
  }
}
