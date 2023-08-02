//
//  UploadInputSchemaViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import Foundation
import HamsterKit
import iFilemanager
import Network
import UIKit

class UploadInputSchemaViewModel {
  private var fileServer: FileServer?
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

  @objc func startFileServer() {
    logger.debug("start file server")
    let fileServer = FileServer(
      port: 80,
      publicDirectory: FileManager.sandboxDirectory
    )
    fileServer.start()
    self.fileServer = fileServer
    self.fileServerRunning = true
  }

  @objc func stopFileServer() {
    logger.debug("stop file server")
    self.fileServer?.shutdown()
    self.fileServerRunning = false
  }
}
