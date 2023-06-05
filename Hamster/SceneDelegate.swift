//
//  SceneDelegate.swift
//  Hamster
//
//  Created by morse on 2023/6/5.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let appSettings = HamsterAppSettings()
    let rimeContext = RimeContext()
    let window = UIWindow(windowScene: windowScene)
    if !appSettings.enableNewUI {
      let settingsViewController = SettingsViewController(appSettings: appSettings, rimeContext: rimeContext)
      window.rootViewController = HamsterNavigationViewController(rootViewController: settingsViewController)
    } else {
      window.rootViewController = UIHostingController(rootView: MainTab())
    }
    self.window = window
    window.makeKeyAndVisible()
  }

  // 通过URL打开App
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let appSettings = HamsterAppSettings()
    let rimeContext = RimeContext()
    let window = UIWindow(windowScene: windowScene)
    if !appSettings.enableNewUI {
      let settingsViewController = SettingsViewController(appSettings: appSettings, rimeContext: rimeContext)
      window.rootViewController = HamsterNavigationViewController(rootViewController: settingsViewController)
      self.window = window
      window.makeKeyAndVisible()

      if let url = URLContexts.first?.url {
        if url.pathExtension.lowercased() == "zip" {
          if let navigationViewController = window.rootViewController as? HamsterNavigationViewController {
            let inputSchemaController = InputSchemaViewController(appSettings: appSettings, rimeContext: rimeContext)
            navigationViewController.popToRootViewController(animated: false)
            navigationViewController.pushViewController(inputSchemaController, animated: true)
            DispatchQueue.global().async {
              inputSchemaController.inputSchemaViewModel.importZipFile(fileURL: url, tableView: inputSchemaController.tableView)
            }
          }
        }
      }
    } else {
      window.rootViewController = UIHostingController(rootView: MainTab())
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
}
