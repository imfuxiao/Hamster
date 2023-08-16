//
//  InputSchemaViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//
import Combine
import HamsterKit
import HamsterUIKit
import OSLog
import ProgressHUD
import RimeKit
import UIKit

public class InputSchemaViewModel {
  // MARK: properties

  public let rimeContext: RimeContext

  public var reloadTableStatePublisher: AnyPublisher<Bool, Never> {
    reloadTableStateSubject.eraseToAnyPublisher()
  }

  private var reloadTableStateSubject = PassthroughSubject<Bool, Never>()

  public var presentDocumentPickerPublisher: AnyPublisher<Bool, Never> {
    presentDocumentPickerSubject.eraseToAnyPublisher()
  }

  /// 注意: 这是私有属性，在 View 中订阅上面的 presentDocumentPickerPublisher 响应是否打开文档View
  /// 而在 ViewModel 内部使用 presentDocumentPickerSubject 发布状态
  private let presentDocumentPickerSubject = PassthroughSubject<Bool, Never>()

  public var errorMessagePublisher: AnyPublisher<ErrorMessage, Never> {
    errorMessageSubject.eraseToAnyPublisher()
  }

  private let errorMessageSubject = PassthroughSubject<ErrorMessage, Never>()

  // MARK: methods

  public init(rimeContext: RimeContext) {
    self.rimeContext = rimeContext
  }
}

extension InputSchemaViewModel {
  @objc func openDocumentPicker() {
    presentDocumentPickerSubject.send(true)
  }

  /// 选择 InputSchema
  func checkboxForInputSchema(_ schema: RimeSchema) async throws {
    let selectSchemas = await rimeContext.selectSchemas
    if !selectSchemas.contains(schema) {
      await rimeContext.appendSelectSchema(schema)
    } else {
      if selectSchemas.count == 1 {
        throw "需要保留至少一个输入方案。"
      }
      await rimeContext.removeSelectSchema(schema)
    }
    reloadTableStateSubject.send(true)
  }

  /// 导入zip文件
  public func importZipFile(fileURL: URL) async {
    Logger.statistics.debug("file.fileName: \(fileURL.path)")

    await ProgressHUD.show("方案导入中……", interaction: false)
    do {
      try await FileManager.default.unzip(fileURL, dst: FileManager.sandboxUserDataDirectory)

      // 加载应用配置
      let configuration = try await HamsterConfigurationRepositories.shared.loadFromYAML(yamlPath: FileManager.hamsterConfigFileOnSandboxSharedSupport)
      HamsterAppDependencyContainer.shared.configuration = configuration

      await ProgressHUD.show("方案部署中……", interaction: false)

      try await rimeContext.deployment(configuration: configuration)

      // 复制输入方案至AppGroup下
      try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)

      // 键盘复制方案标志
      UserDefaults.hamster.overrideRimeDirectory = true

      // 发布
      reloadTableStateSubject.send(true)
      await ProgressHUD.showSuccess("导入成功", interaction: false, delay: 1.5)
    } catch {
      await ProgressHUD.dismiss()
      Logger.statistics.debug("zip \(error)")
      errorMessageSubject.send(ErrorMessage(title: "导入Zip文件", message: "导入失败, \(error.localizedDescription)"))
    }
  }
}
