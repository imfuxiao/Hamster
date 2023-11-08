//
//  RimeDeployIntent.swift
//  Hamster
//
//  Created by morse on 22/6/2023.
//

import AppIntents
import HamsteriOS
import HamsterKeyboardKit
import HamsterKit
import OSLog

@available(iOS 16.0, *)
struct RimeDeployIntent: AppIntent {
  static var title: LocalizedStringResource = "RIME 重新部署"

  static var openAppWhenRun: Bool {
    return true
  }

  static var authenticationPolicy: IntentAuthenticationPolicy {
    .requiresAuthentication
  }

  static var description = IntentDescription("仓输入法 - RIME 重新部署")

  @MainActor
  func perform() async throws -> some ReturnsValue {
    HamsterAppDependencyContainer.shared.mainViewModel.navigationToRIME()
    HamsterAppDependencyContainer.shared.mainViewModel.execShortcutCommand(.rimeDeploy)
    return .result()
  }
}
