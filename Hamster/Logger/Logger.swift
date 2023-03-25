//
//  Logger.swift
//  HamsterApp
//
//  Created by morse on 2023/3/24.
//

import Foundation
import SwiftyBeaver

public class Logger {
  public static let shared: Logger = .init(AppConstants.logFileURL)

  public let log: SwiftyBeaver.Type

  private var stderrPipe = Pipe()

  public init(_ fileURL: URL) {
    let log = SwiftyBeaver.self

    // 控制台
    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss$d $L $M"
    log.addDestination(console)

    // 判断是否有权限读写日志文件: 扩展键盘需要完全访问权限才能读写AppGroup下日志文件
    var logFileWriteable = false
    let fm = FileManager.default
    if !fm.fileExists(atPath: fileURL.path) {
      if fm.createFile(atPath: fileURL.path, contents: nil) {
        logFileWriteable = true
      }
    } else {
      logFileWriteable = FileManager.default.isWritableFile(atPath: fileURL.path)
    }

    if logFileWriteable {
      // 默认: 日志文件数量为1. 文件大小为5M
      let file = FileDestination(logFileURL: fileURL)
      #if DEBUG
        file.minLevel = .debug
      #else
        file.minLevel = .info
      #endif
      log.addDestination(file)
    } else {
      log.error("log file cannot writeable. file: \(fileURL.path)")
    }

    log.debug(["log path": fileURL.path])

    // 将依赖库中stderr中日志同步到日志库中
    setvbuf(stderr, nil, _IONBF, 0)
    dup2(stderrPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    // listening on the readabilityHandler
    stderrPipe.fileHandleForReading.readabilityHandler = { handle in
      let data = handle.availableData
      if let str = String(data: data, encoding: .ascii) {
        log.info(str)
      }
    }

    self.log = log
  }
}
