//
//  RimeViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import Foundation
import HamsterKeyboardKit
import HamsterKit
import OSLog
import ProgressHUD
import UIKit

public class RimeViewModel {
  public let rimeContext: RimeContext

  private let rimeRestSubject = PassthroughSubject<() -> Void, Never>()
  public var rimeRestPublished: AnyPublisher<() -> Void, Never> {
    rimeRestSubject.eraseToAnyPublisher()
  }

  private let openRimeLoggerViewSubject = PassthroughSubject<Bool, Never>()
  public var openRimeLoggerViewPublished: AnyPublisher<Bool, Never> {
    openRimeLoggerViewSubject.eraseToAnyPublisher()
  }

  private lazy var stdoutHandle = FileHandle.standardOutput
  private lazy var readStderrPipe: Pipe = {
    let pipe = Pipe()
    setvbuf(stderr, nil, _IONBF, 0)
    dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    return pipe
  }()

  deinit {
    try? stdoutHandle.close()
  }

  // 简繁切换键值
  public var keyValueOfSwitchSimplifiedAndTraditional: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.rime?.keyValueOfSwitchSimplifiedAndTraditional ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.rime?.keyValueOfSwitchSimplifiedAndTraditional = newValue
      HamsterAppDependencyContainer.shared.applicationConfiguration.rime?.keyValueOfSwitchSimplifiedAndTraditional = newValue
    }
  }

  // 是否覆盖词库文件
  // 非造词用户保持默认值 true
  public var overrideDictFiles: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.rime?.overrideDictFiles ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.rime?.overrideDictFiles = newValue
      HamsterAppDependencyContainer.shared.applicationConfiguration.rime?.overrideDictFiles = newValue
    }
  }

  lazy var settings: [SettingSectionModel] = [
    .init(
      title: L10n.Rime.SimpTradSwtich.title,
      footer: L10n.Rime.SimpTradSwtich.footer,
      items: [
        .init(
          icon: UIImage(systemName: "square.and.pencil"),
          placeholder: L10n.Rime.SimpTradSwtich.placeholder,
          type: .textField,
          textValue: { [unowned self] in keyValueOfSwitchSimplifiedAndTraditional },
          textHandled: { [unowned self] in
            keyValueOfSwitchSimplifiedAndTraditional = $0
          }
        )
      ]
    ),
    .init(
      footer: L10n.Rime.OverrideDict.footer,
      items: [
        .init(
          text: L10n.Rime.OverrideDict.text,
          type: .toggle,
          toggleValue: { [unowned self] in overrideDictFiles },
          toggleHandled: { [unowned self] in
            overrideDictFiles = $0
          }
        )
      ]
    ),
    .init(
      items: [
        .init(
          text: L10n.Rime.Logger.text,
          accessoryType: .disclosureIndicator,
          type: .navigation,
          navigationAction: { [unowned self] in
            openRimeLoggerViewSubject.send(true)
          }
        )
      ]
    ),
    .init(
      items: [
        .init(
          text: L10n.Rime.Deploy.text,
          type: .button,
          buttonAction: { [unowned self] in
            Task {
              await rimeDeploy()
              reloadTableSubject.send(true)
            }
          },
          favoriteButton: .rimeDeploy
        )
      ]
    ),
    .init(
      footer: L10n.Rime.Sync.footer(Self.rimeSyncConfigSample),
      items: [
        .init(
          text: L10n.Rime.Sync.text,
          type: .button,
          buttonAction: { [unowned self] in
            Task {
              await rimeSync()
            }
          },
          favoriteButton: .rimeSync
        )
      ]
    ),
    .init(items: [
      .init(
        text: L10n.Rime.Reset.text,
        textTintColor: .systemRed,
        type: .button,
        buttonAction: { [unowned self] in
          rimeRestSubject.send { [unowned self] in
            Task {
              await rimeRest()
              reloadTableSubject.send(true)
            }
          }
        }
      )
    ])
  ]

  private var reloadTableSubject = PassthroughSubject<Bool, Never>()
  public var reloadTablePublished: AnyPublisher<Bool, Never> {
    reloadTableSubject.eraseToAnyPublisher()
  }

  init(rimeContext: RimeContext) {
    self.rimeContext = rimeContext
  }
}

public extension RimeViewModel {
  /// RIME 日志记录
  private func rimeLogger() -> (FileHandle?, URL) {
    let fileName = DateFormatter.tempFileNameStyle.string(from: Date()) + ".log"
    let loggerDirectory = FileManager.sandboxRimeLogDirectory

    try? FileManager.createDirectory(override: false, dst: loggerDirectory)

    // 日志文件最多保存 10 个，排序删除最早的文件
    if let urls = try? FileManager.default.contentsOfDirectory(
      at: loggerDirectory,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    ), urls.count >= 10, let url = urls.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }).last {
      try? FileManager.default.removeItem(at: url)
    }

    // 创建日志文件
    let filePath = loggerDirectory.appendingPathComponent(fileName)
    FileManager.default.createFile(atPath: filePath.path, contents: nil)
    let fileHandle = try? FileHandle(forWritingTo: filePath)

    // listening on the readabilityHandler
    readStderrPipe.fileHandleForReading.readabilityHandler = { [unowned self] handle in
      let data = handle.availableData
      try? fileHandle?.write(contentsOf: data)
      try? stdoutHandle.write(contentsOf: data)
    }

    return (fileHandle, filePath)
  }

  /// 关闭 RIME Logger 日志
  private func closeRimeLogger(_ fileHandle: FileHandle?) {
    readStderrPipe.fileHandleForReading.readabilityHandler = { [unowned self] handle in
      let data = handle.availableData
      try? stdoutHandle.write(contentsOf: data)
    }
    try? fileHandle?.close()
  }

  /// 检测 RIME Logger 日志是否存在异常
  func checkRimeLogger(_ fileURL: URL) async {
    var errorLines = [String]()
    guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else { return }
    guard let data = try? fileHandle.readToEnd() else { return }
    guard let str = String(data: data, encoding: .utf8) else { return }
    let lines = str.split(separator: "\n").map { String($0) }
    for (index, line) in lines.enumerated() {
      if line.isMatch(regex: ".*[1-9] failure.*") {
        errorLines.append("\(index + 1)")
      }
    }
    try? fileHandle.close()

    if !errorLines.isEmpty {
      await ProgressHUD.banner(L10n.Rime.Logger.bannerTitle, L10n.Rime.Logger.bannerMessage(fileURL.lastPathComponent, errorLines.joined(separator: ",")), delay: 5)
    }
  }

  /// RIME 部署
  func rimeDeploy() async {
    let (fileHandle, filePath) = rimeLogger()
    await ProgressHUD.animate(L10n.Rime.Deploy.deploying, AnimationType.circleRotateChase, interaction: false)
    var hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration
    do {
      try rimeContext.deployment(configuration: &hamsterConfiguration)
      await checkRimeLogger(filePath)
      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration
      await ProgressHUD.success(L10n.Rime.Deploy.success, interaction: false, delay: 1.5)
    } catch {
      // try? FileHandle.standardError.write(contentsOf: error.localizedDescription.data(using: .utf8) ?? Data())
      Logger.statistics.error("rime deploy error: \(error)")
      await ProgressHUD.failed(error, interaction: false, delay: 5)
    }
    closeRimeLogger(fileHandle)
  }

  /// RIME 同步
  func rimeSync() async {
    let (fileHandle, filePath) = rimeLogger()
    do {
      await ProgressHUD.animate(L10n.Rime.Sync.syncing, interaction: false)

      let hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration

      // 先打开iCloud地址，防止Crash
      _ = URL.iCloudDocumentURL

      // 增加同步路径检测（sync_dir），检测是否有权限写入。
      if let syncDir = FileManager.sandboxInstallationYaml.getSyncPath() {
        if !FileManager.default.fileExists(atPath: syncDir) {
          do {
            try FileManager.default.createDirectory(atPath: syncDir, withIntermediateDirectories: true)
          } catch {
            throw L10n.Rime.Sync.writeError(syncDir)
          }
        } else {
          if !FileManager.default.isWritableFile(atPath: syncDir) {
            throw L10n.Rime.Sync.writeError(syncDir)
          }
        }
      }

      try rimeContext.syncRime(configuration: hamsterConfiguration)
      await checkRimeLogger(filePath)
      await ProgressHUD.success(L10n.Rime.Sync.success, interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rime sync error: \(error)")
      await ProgressHUD.failed(L10n.Rime.Sync.failed(error.localizedDescription), interaction: false, delay: 3)
    }
    closeRimeLogger(fileHandle)
  }

  /// Rime重置
  func rimeRest() async {
    await ProgressHUD.animate(L10n.Rime.Reset.reseting, interaction: false)
    do {
      try rimeContext.restRime()

      // 重置应用配置
      HamsterAppDependencyContainer.shared.resetHamsterConfiguration()

      // 重新读取 Hamster.yaml 生成 configuration
      let hamsterConfiguration = try HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnSandboxSharedSupport)

      // 保存配置至 build/hamster.yaml
      // try? HamsterConfigurationRepositories.shared.saveToYAML(config: configuration, path: FileManager.hamsterConfigFileOnBuild)
  //    try? HamsterConfigurationRepositories.shared.saveToJSON(
  //      config: configuration,
  //      path: FileManager.sandboxUserDataDirectory.appendingPathComponent("/build/hamster.json")
  //    )
      try? HamsterConfigurationRepositories.shared.saveToPropertyList(
        config: hamsterConfiguration,
        path: FileManager.sandboxUserDataDirectory.appendingPathComponent("/build/hamster.plist")
      )

      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration

      HamsterAppDependencyContainer.shared.applicationConfiguration = HamsterConfiguration(
        general: GeneralConfiguration(),
        toolbar: KeyboardToolbarConfiguration(),
        keyboard: KeyboardConfiguration(),
        rime: RimeConfiguration(),
        swipe: KeyboardSwipeConfiguration(),
        keyboards: nil
      )

      // TODO: 内置雾凇方案，将默认选择方案改为雾凇拼音
      let rimeSchema = RimeSchema(schemaId: "rime_ice", schemaName: "雾凇拼音")
      rimeContext.selectSchemas = [rimeSchema]
      rimeContext.currentSchema = rimeSchema

      /// 在另存一份用于应用配置还原
      try HamsterConfigurationRepositories.shared.saveToUserDefaultsOnDefault(hamsterConfiguration)

      await ProgressHUD.success(L10n.Rime.Reset.success, interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rimeRest() error: \(error)")
      await ProgressHUD.failed(L10n.Rime.Reset.failed, interaction: false, delay: 3)
    }
  }
}

public extension RimeViewModel {
  static let rimeSyncConfigSample = """
  # \(L10n.Rime.Sync.SampleConfig.comment1)
  installation_id: "hamster"
  # \(L10n.Rime.Sync.SampleConfig.comment2)/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents
  # \(L10n.Rime.Sync.SampleConfig.comment3)
  sync_dir: "/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents/sync"
  """
}
