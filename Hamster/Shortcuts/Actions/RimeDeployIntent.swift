//
//  RimeDeployIntent.swift
//  Hamster
//
//  Created by morse on 22/6/2023.
//

import AppIntents

@available(iOS 16.0, *)
struct RimeDeployIntent: AppIntent {
  static var title: LocalizedStringResource = "重新部署"

  static var description =
    IntentDescription("仓输入法 RIME 重新部署")

  @MainActor
  func perform() async throws -> some IntentResult {
    try RimeContext.shared.redeployment(HamsterAppSettings.shared)
    let resetHandled = HamsterAppSettings.shared.resetRimeParameter()
    Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")
    return .result(dialog: .init("重新部署完成"))
  }
}
