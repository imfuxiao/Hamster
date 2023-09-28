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

  let rimeContext = HamsterAppDependencyContainer.shared.rimeContext

  func perform() async throws -> some ReturnsValue & ProvidesDialog {
    var hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration
    do {
      try await rimeContext.deployment(configuration: hamsterConfiguration)

      // 读取 Rime 目录下 hamster.yaml 配置文件，如果存在
      if FileManager.default.fileExists(atPath: FileManager.hamsterConfigFileOnUserDataSupport.path) {
        hamsterConfiguration = try HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnUserDataSupport)
      }

      // 读取 Rime 目录下 hamster.custom.yaml 配置文件(如果存在)，
      // 并对相异的配置做 merge 合并（已 hamster.custom.yaml 文件为主）
      if FileManager.default.fileExists(atPath: FileManager.hamsterPatchConfigFileOnUserDataSupport.path) {
        let patchConfiguration = try HamsterConfigurationRepositories.shared.loadPatchFromYAML(yamlPath: FileManager.hamsterPatchConfigFileOnUserDataSupport)
        if let configuration = patchConfiguration.patch {
          hamsterConfiguration = try hamsterConfiguration.merge(
            with: configuration,
            uniquingKeysWith: { _, patchValue in patchValue }
          )
        }
      }

      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration

      return .result(dialog: .init("重新部署完成"))
    } catch {
      Logger.statistics.error("RimeDeployIntent failed: \(error)")
      return .result(dialog: .init("重新部署失败:\(error.localizedDescription)"))
    }
  }
}
