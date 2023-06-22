//
//  SceneDelegate.swift
//  Hamster
//
//  Created by morse on 2023/6/5.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let appSettings = HamsterAppSettings.shared
    let rimeContext = RimeContext.shared
    let window = UIWindow(windowScene: windowScene)
    if !appSettings.enableNewUI {
      let settingsViewController = SettingsViewController(appSettings: appSettings, rimeContext: rimeContext)
      window.rootViewController = HamsterNavigationViewController(rootViewController: settingsViewController)
      self.window = window
      window.makeKeyAndVisible()

      // 通过快捷方式打开
      if let shortItem = connectionOptions.shortcutItem, let shortItemType = ShortcutItemType(rawValue: shortItem.localizedTitle) {
        switch shortItemType {
        case .rimeDeploy:
          settingsViewController.rimeViewModel.rimeDeploy()
        case .rimeSync:
          settingsViewController.rimeViewModel.rimeSync()
        case .rimeReset:
          settingsViewController.rimeViewModel.rimeRest()
        }
      }
    } else {
      window.rootViewController = UIHostingController(rootView: MainTab())
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  // 通过URL打开App
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let appSettings = HamsterAppSettings.shared
    let rimeContext = RimeContext.shared
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

  // 程序已启动下，通过 quick action 打开
  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    guard let window = window else { return }
    guard let rootController = window.rootViewController else { return }
    guard let navigationController = rootController as? HamsterNavigationViewController else { return }

    navigationController.popToRootViewController(animated: false)

    guard let settingsViewController = navigationController.topViewController as? SettingsViewController else { return }

    // 通过快捷方式打开
    if let shortItemType = ShortcutItemType(rawValue: shortcutItem.localizedTitle) {
      switch shortItemType {
      case .rimeDeploy:
        settingsViewController.rimeViewModel.rimeDeploy()
      case .rimeSync:
        settingsViewController.rimeViewModel.rimeSync()
      case .rimeReset:
        settingsViewController.rimeViewModel.rimeRest()
      }
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
    let application = UIApplication.shared
    let rimeDeploy = UIApplicationShortcutItem(type: "RIME", localizedTitle: ShortcutItemType.rimeDeploy.rawValue)
    let rimeSync = UIApplicationShortcutItem(type: "RIME", localizedTitle: ShortcutItemType.rimeSync.rawValue)
//    let rimeReset = UIApplicationShortcutItem(type: "RIME", localizedTitle: ShortcutItemType.rimeReset.rawValue)
    application.shortcutItems = [rimeDeploy, rimeSync]
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

enum ShortcutItemType: String {
  case rimeDeploy = "RIME重新部署"
  case rimeSync = "RIME同步"
  case rimeReset = "RIME重置"
}
