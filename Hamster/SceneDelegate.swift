//
//  SceneDelegate.swift
//  Hamster
//
//  Created by morse on 2023/6/5.
//

import HamsteriOS
import HamsterKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    if window == nil {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = HamsterAppDependencyContainer.shared.makeRootController()
      self.window = window
      window.makeKeyAndVisible()
    }

    /// 外部导入 zip 文件
    if let url = connectionOptions.urlContexts.first?.url {
      if url.pathExtension.lowercased() == "zip" {
        Task {
          HamsterAppDependencyContainer.shared.mainViewModel.navigationToInputSchema()
          await HamsterAppDependencyContainer.shared.inputSchemaViewModel.importZipFile(fileURL: url)
        }
        return
      }

      // url.query(): 获取 `URL` 查询参数
      // url.lastPathComponent 获取 `URL` 中 `/a/b` 中最后一个 b
      let components = url.lastPathComponent
      if let subView = SettingsSubView(rawValue: components) {
        HamsterAppDependencyContainer.shared.mainViewModel.navigation(subView)
      }
    }

    // 通过快捷方式打开
    if let shortItem = connectionOptions.shortcutItem,
       let shortItemType = ShortcutItemType(rawValue: shortItem.localizedTitle),
       shortItemType != .none
    {
      HamsterAppDependencyContainer.shared.mainViewModel.navigationToRIME()
      HamsterAppDependencyContainer.shared.mainViewModel.execShortcutCommand(shortItemType)
    }
  }

  // 通过URL打开App
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    if window == nil {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = HamsterAppDependencyContainer.shared.makeRootController()
      self.window = window
      window.makeKeyAndVisible()
    }

    /// 外部导入 zip 文件
    if let url = URLContexts.first?.url {
      if url.pathExtension.lowercased() == "zip" {
        Task {
          HamsterAppDependencyContainer.shared.mainViewModel.navigationToInputSchema()
          await HamsterAppDependencyContainer.shared.inputSchemaViewModel.importZipFile(fileURL: url)
        }
        return
      }

      // url.query(): 获取 `URL` 查询参数
      // url.lastPathComponent 获取 `URL` 中 `/a/b` 中最后一个 b
      let components = url.lastPathComponent
      if let subView = SettingsSubView(rawValue: components) {
        HamsterAppDependencyContainer.shared.mainViewModel.navigation(subView)
      }
    }
  }

  /// 程序已启动下，通过 quick action 打开
  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    guard let window = window else { return }
    guard let rootController = window.rootViewController else { return }
    guard let mainViewController = rootController as? MainViewController else { return }

    mainViewController.navigationController?.popViewController(animated: false)

    // 通过快捷方式打开
    if let shortItemType = ShortcutItemType(rawValue: shortcutItem.localizedTitle), shortItemType != .none {
      HamsterAppDependencyContainer.shared.mainViewModel.navigationToRIME()
      HamsterAppDependencyContainer.shared.mainViewModel.execShortcutCommand(shortItemType)
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

  /// 应用注册 quick action
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
