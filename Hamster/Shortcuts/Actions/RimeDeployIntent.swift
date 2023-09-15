//
//  RimeDeployIntent.swift
//  Hamster
//
//  Created by morse on 22/6/2023.
//

import AppIntents
import HamsteriOS
import HamsterKit
import OSLog

@available(iOS 16.0, *)
struct RimeDeployIntent: AppIntent {
  static var title: LocalizedStringResource = "RIME 重新部署"

  static var description = IntentDescription("仓输入法 - RIME 重新部署")

  let rimeContext = HamsterAppDependencyContainer.shared.rimeContext

  func perform() async throws -> some ReturnsValue & ProvidesDialog {
    let configuration = HamsterAppDependencyContainer.shared.configuration
    do {
      try await rimeContext.deployment(configuration: configuration)
      return .result(dialog: .init("重新部署完成"))
    } catch {
      Logger.statistics.error("RimeDeployIntent failed: \(error)")
      return .result(dialog: .init("重新部署失败"))
    }
  }
}
