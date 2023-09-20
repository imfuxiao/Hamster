//
//  UploadInputSchemaViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import Foundation
import HamsterFileServer
import HamsterKit
import Network
import OSLog
import UIKit

class UploadInputSchemaViewModel {
  private lazy var fileServer: FileServer = {
    let server = FileServer(
      port: 80,
      publicDirectory: FileManager.sandboxDirectory
    )
    return server
  }()

  @Published
  public private(set) var fileServerRunning = false

  private var wifiEnable = false
}

extension UploadInputSchemaViewModel {
  func startWiFiMonitor() {
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    monitor.pathUpdateHandler = { [unowned self] path in
      if path.status == .satisfied {
        self.wifiEnable = true
        monitor.cancel()
        return
      }
      self.wifiEnable = false
      monitor.cancel()
    }
    monitor.start(queue: .main)
  }

  @objc func managerfileServer() {
    if fileServerRunning {
      Logger.statistics.debug("stop file server")
      self.fileServer.shutdown()
      fileServerRunning = false
    } else {
      Logger.statistics.debug("start file server")
      self.fileServer.start()
      fileServerRunning = true
    }
  }

  func stopFileServer() {
    fileServerRunning = false
    self.fileServer.shutdown()
  }
}
