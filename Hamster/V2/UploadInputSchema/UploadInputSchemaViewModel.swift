//
//  UploadInputSchemaViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import Foundation
import iFilemanager
import Network
import UIKit

class UploadInputSchemaViewModel {
  init() {}

  var wifiEnable = false
  private var fileServer: FileServer?
  var fileServerRunning = false
}

extension UploadInputSchemaViewModel {
  func startMonitor() {
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

  @objc func startFileServer() {
    Logger.shared.log.debug("start file server")
    let fileServer = FileServer(
      port: 80,
      publicDirectory: RimeContext.sandboxDirectory
    )
    fileServer.start()
    self.fileServer = fileServer
    self.fileServerRunning = true
  }

  @objc func stopFileServer() {
    Logger.shared.log.debug("stop file server")
    self.fileServer?.shutdown()
    self.fileServerRunning = false
  }
}
