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
      title: "简繁切换",
      footer: "配置文件中`switches`简繁转换选项的配置名称，仓用于中文简体与繁体之间快速切换。",
      items: [
        .init(
          icon: UIImage(systemName: "square.and.pencil"),
          placeholder: "简繁切换键值",
          type: .textField,
          textValue: { [unowned self] in keyValueOfSwitchSimplifiedAndTraditional },
          textHandled: { [unowned self] in
            keyValueOfSwitchSimplifiedAndTraditional = $0
          }
        ),
      ]
    ),
    .init(
      footer: "如果您未使用自造词功能，请保持保持默认开启状态。",
      items: [
        .init(
          text: "部署时覆盖键盘词库文件",
          type: .toggle,
          toggleValue: { [unowned self] in overrideDictFiles },
          toggleHandled: { [unowned self] in
            overrideDictFiles = $0
          }
        ),
      ]
    ),
    .init(
      items: [
        .init(
          text: "RIME 日志",
          accessoryType: .disclosureIndicator,
          type: .navigation,
          navigationAction: { [unowned self] in
            openRimeLoggerViewSubject.send(true)
          }
        ),
      ]
    ),
    .init(
      items: [
        .init(
          text: "重新部署",
          type: .button,
          buttonAction: { [unowned self] in
            Task {
              await rimeDeploy()
              reloadTableSubject.send(true)
            }
          },
          favoriteButton: .rimeDeploy
        ),
      ]
    ),
    .init(
      footer: """
      注意：
      1. RIME同步自定义参数，需要手工添加至Rime目录下的`installation.yaml`文件中(如果没有，需要则自行创建)；
      2. 同步配置示例：(点击可复制)
      ```
      \(Self.rimeSyncConfigSample)
      ```
      """,
      items: [
        .init(
          text: "RIME同步",
          type: .button,
          buttonAction: { [unowned self] in
            Task {
              await rimeSync()
            }
          },
          favoriteButton: .rimeSync
        ),
      ]
    ),
    .init(items: [
      .init(
        text: "RIME重置",
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
      ),
    ]),
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
  typealias loggerFileCloseHandler = (FileHandle) -> Void
  /// RIME 日志记录
  func rimeLogger() -> (FileHandle?, URL) {
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
  func closeRimeLogger(_ fileHandle: FileHandle?) {
    readStderrPipe.fileHandleForReading.readabilityHandler = { [unowned self] handle in
      let data = handle.availableData
      try? stdoutHandle.write(contentsOf: data)
    }
    try? fileHandle?.close()
  }

  /// 检测 RIME Logger 日志是否存在异常
  func checkRimeLogger(_ fileURL: URL) throws {
    var errorLines = [String]()
    guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else { return }
    guard let data = try? fileHandle.readToEnd() else { return }
    guard let str = String(data: data, encoding: .utf8) else { return }
    let lines = str.split(separator: "\n").map { String($0) }
    for (index, line) in lines.enumerated() {
      if line.isMatch(regex: ".*[1-9] failure.*") {
        errorLines.append("line \(index + 1):" + line)
      }
    }
    try? fileHandle.close()

    if !errorLines.isEmpty {
      ProgressHUD.banner("日志:\(fileURL.lastPathComponent)", errorLines.joined(separator: "\n"), delay: 5)
      throw "RIME 部署异常"
    }
  }

  /// RIME 部署
  func rimeDeploy() async {
    let (fileHandle, filePath) = rimeLogger()
    defer {
      closeRimeLogger(fileHandle)
    }
    await ProgressHUD.animate("RIME部署中, 请稍候……", AnimationType.circleRotateChase, interaction: false)
    var hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration
    do {
      try rimeContext.deployment(configuration: &hamsterConfiguration)
      try checkRimeLogger(filePath)
      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration
      await ProgressHUD.success("部署成功", interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rime deploy error: \(error)")
      await ProgressHUD.failed(error, interaction: false, delay: 5)
    }
  }

  /// RIME 同步
  func rimeSync() async {
    let (fileHandle, filePath) = rimeLogger()
    defer {
      closeRimeLogger(fileHandle)
    }
    do {
      await ProgressHUD.animate("RIME同步中, 请稍候……", interaction: false)

      let hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration

      // 先打开iCloud地址，防止Crash
      _ = URL.iCloudDocumentURL

      // 增加同步路径检测（sync_dir），检测是否有权限写入。
      if let syncDir = FileManager.sandboxInstallationYaml.getSyncPath() {
        if !FileManager.default.fileExists(atPath: syncDir) {
          do {
            try FileManager.default.createDirectory(atPath: syncDir, withIntermediateDirectories: true)
          } catch {
            throw "同步地址无写入权限：\(syncDir)"
          }
        } else {
          if !FileManager.default.isWritableFile(atPath: syncDir) {
            throw "同步地址无写入权限：\(syncDir)"
          }
        }
      }

      try rimeContext.syncRime(configuration: hamsterConfiguration)
      try checkRimeLogger(filePath)
      await ProgressHUD.success("同步成功", interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rime sync error: \(error)")
      await ProgressHUD.failed("同步失败:\(error.localizedDescription)", interaction: false, delay: 3)
    }
  }

  /// Rime重置
  func rimeRest() async {
    await ProgressHUD.animate("RIME重置中, 请稍候……", interaction: false)
    do {
      try rimeContext.restRime()

      // 重置应用配置
      HamsterAppDependencyContainer.shared.resetHamsterConfiguration()

      // 重新读取 Hamster.yaml 生成 configuration
      let hamsterConfiguration = try HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnSandboxSharedSupport)
      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration

      HamsterAppDependencyContainer.shared.applicationConfiguration = HamsterConfiguration(
        general: GeneralConfiguration(),
        toolbar: KeyboardToolbarConfiguration(),
        keyboard: KeyboardConfiguration(),
        rime: RimeConfiguration(),
        swipe: KeyboardSwipeConfiguration(),
        keyboards: nil
      )

      /// 在另存一份用于应用配置还原
      try HamsterConfigurationRepositories.shared.saveToUserDefaultsOnDefault(hamsterConfiguration)

      await ProgressHUD.success("重置成功", interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rimeRest() error: \(error)")
      await ProgressHUD.failed("重置失败", interaction: false, delay: 3)
    }
  }
}

public extension RimeViewModel {
  static let rimeSyncConfigSample = """
  # id可以自定义，但不能其他终端定义的ID重复
  installation_id: "hamster"
  # 仓的iOS中iCloud前缀路径固定为：/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents
  # iOS中的路径与MacOS及Windows的iCloud路径是不同的
  sync_dir: "/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents/sync"
  """
}
