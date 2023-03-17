//
//  HamsterApp.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import SwiftUI

@main
struct HamsterApp: App {
  let appSetings = HamsterAppSettings()
  let rimeEngine = RimeEngine.shared
  @State var launchScreenState = true

  var body: some Scene {
    WindowGroup {
      ZStack {
        if launchScreenState {
          LaunchScreen()
        } else {
          ContentView()
        }
      }
      .onAppear {
        if appSetings.isFirstLaunch {
          do {
            try RimeEngine.initAppGroupSharedSupportDirectory(override: true)
            try RimeEngine.initAppGroupUserDataDirectory(override: true)
          } catch {
            appSetings.isFirstLaunch = true
            // TODO: 日志处理
            fatalError("unresolved error: \(error), \(error.localizedDescription)")
          }
          appSetings.isFirstLaunch = false
        }

        rimeEngine.setupRime(
          sharedSupportDir: RimeEngine.appGroupSharedSupportDirectoryURL.path,
          userDataDir: RimeEngine.appGroupUserDataDirectoryURL.path
        )
        rimeEngine.startRime()
        launchScreenState = false
      }
      .environmentObject(appSetings)
      .environmentObject(rimeEngine)
    }
  }
}
