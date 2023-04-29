//
//  File+FileManager.swift
//  HamsterApp
//
//  Created by morse on 28/4/2023.
//

import Foundation

extension FileManager {
  /// 获取制定URL下文件或目录URL
  func getFilesAndDirectories(for url: URL) -> [URL] {
    do {
      return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
    } catch {
      Logger.shared.log.error("Error getting files and directories - \(error.localizedDescription)")
      return []
    }
  }

  /// 获取指定URL路径下 .schema.yaml 文件URL
  func getSchemesFile(for url: URL) -> [URL] {
    getFilesAndDirectories(for: url).filter { $0.lastPathComponent.hasSuffix(".schema.yaml") }
  }
  

  /// 获取指定URL的文件内容
  func getStringFromFile(at path: URL) -> String? {
    guard let data = FileManager.default.contents(atPath: path.path) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }
}
