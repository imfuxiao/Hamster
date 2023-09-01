//
//  RimeSyncIntent.swift
//  Hamster
//
//  Created by morse on 22/6/2023.
//

import AppIntents
import HamsterKit
import OSLog

@available(iOS 16.0, *)
struct RimeSyncIntent: AppIntent {
  static var title: LocalizedStringResource = "RIME同步"

  static var description =
    IntentDescription("仓输入法 RIME 同步")

  let rimeContext = RimeContext()

  @MainActor
  func perform() async throws -> some IntentResult {
    // 先打开iCloud地址，防止Crash
    _ = URL.iCloudDocumentURL
    do {
      try await rimeContext.syncRime()
      return .result(dialog: .init("RIME 同步完成"))
    } catch {
      Logger.statistics.error("RimeSyncIntent failed: \(error)")
      return .result(dialog: .init("RIME 同步失败"))
    }
  }
}