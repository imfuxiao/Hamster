//
//  RimeDeployBackgroundIntent.swift
//  Hamster
//
//  Created by morse on 2023/11/8.
//

import AppIntents
import HamsteriOS
import HamsterKeyboardKit
import HamsterKit
import OSLog

@available(iOS 16.0, *)
struct RimeDeployBackgroundIntent: AppIntent {
  static var title: LocalizedStringResource = "RIME 重新部署(静默)"

  static var openAppWhenRun: Bool {
    return false
  }

  static var authenticationPolicy: IntentAuthenticationPolicy {
    .alwaysAllowed
  }

  static var description = IntentDescription("仓输入法 - RIME 重新部署，后台静默运行，不会打开应用，但可能会有超时的异常。")

  @MainActor
  func perform() async throws -> some ReturnsValue<Bool> {
    var hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration
    do {
      try HamsterAppDependencyContainer.shared.rimeContext.deployment(configuration: &hamsterConfiguration)
      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration
      return .result(value: true)
    } catch {
      return .result(value: false)
    }
  }
}
