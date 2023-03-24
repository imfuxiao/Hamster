//
//  Logger.swift
//  HamsterApp
//
//  Created by morse on 2023/3/24.
//

import Foundation
import SwiftyBeaver

public class Logger {
  public static let shared: Logger = .init()

  public let log: SwiftyBeaver.Type

  private var stderrPipe = Pipe()

  private init() {
    let log = SwiftyBeaver.self
    // 日志初始化
    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss$d $L $M"

    let file = FileDestination(logFileURL: AppConstants.logFileURL)

    #if DEBUG
      file.minLevel = .debug
    #else
      file.minLevel = .info
    #endif

    log.addDestination(console)
    log.addDestination(file)

    log.debug(["log path": AppConstants.logFileURL.path])

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
