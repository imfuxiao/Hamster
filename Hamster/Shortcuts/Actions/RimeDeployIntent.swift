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

  static var description = IntentDescription("仓输入法 - RIME 重新部署")

  func perform() async throws -> some ReturnsValue & ProvidesDialog {
    var hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration
    do {
      if hamsterConfiguration.general?.enableAppleCloud ?? false {
        // 先打开iCloud地址，防止Crash
        _ = URL.iCloudDocumentURL
      }

      try HamsterAppDependencyContainer.shared.rimeContext.deployment(configuration: &hamsterConfiguration)

      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration

      return .result(dialog: .init("重新部署完成"))
    } catch {
      Logger.statistics.error("RimeDeployIntent failed: \(error)")
      return .result(dialog: .init("重新部署失败:\(error.localizedDescription)"))
    }
  }
}
