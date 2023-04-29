//
//  File+Zip.swift
//  HamsterApp
//
//  Created by morse on 28/4/2023.
//

import Foundation
import ZIPFoundation

// Zip文件解析异常
struct ZipParsingError: Error {
  let message: String
}

extension FileManager {
  func unzip(_ data: Data) throws -> (Bool, Error?) {
    let tempZipURL = temporaryDirectory.appendingPathComponent("temp.zip")
    if fileExists(atPath: tempZipURL.path) {
      try removeItem(at: tempZipURL)
    }
    createFile(atPath: tempZipURL.path, contents: data)
    return try unzip(tempZipURL)
  }

  // 解压至用户数据目录
  // 返回值
  // Bool 处理是否成功
  // Error: 处理失败的Error
  func unzip(_ zipURL: URL) throws -> (Bool, Error?) {
    var tempURL = zipURL

    // 检测是否为iCloudURL, 需要特殊处理
    if zipURL.path.contains("com~apple~CloudDocs") {
      // iCloud中的URL须添加安全访问资源语句，否则会异常：Operation not permitted
      // startAccessingSecurityScopedResource与stopAccessingSecurityScopedResource必须成对出现
      if !zipURL.startAccessingSecurityScopedResource() {
        throw ZipParsingError(message: "Zip文件读取权限受限")
      }

      let tempPath = temporaryDirectory.appendingPathComponent(zipURL.lastPathComponent)

      // 临时文件如果存在需要先删除
      if fileExists(atPath: tempPath.path) {
        try removeItem(at: tempPath)
      }

      try copyItem(atPath: zipURL.path, toPath: tempPath.path)

      // 停止读取url文件
      zipURL.stopAccessingSecurityScopedResource()

      tempURL = tempPath
    }

    // 读取ZIP内容
    guard let archive = Archive(url: tempURL, accessMode: .read) else {
      return (false, ZipParsingError(message: "读取Zip文件异常"))
    }

    // 查找解压的文件夹里有没有名字包含schema.yaml 的文件
    guard let _ = archive.filter({ $0.path.contains("schema.yaml") }).first else {
      return (false, ZipParsingError(message: "Zip文件未包含输入方案文件"))
    }

    // 解压前先删除原Rime目录
    try removeItem(at: RimeEngine.appGroupUserDataDirectoryURL)
    try unzipItem(at: tempURL, to: RimeEngine.appGroupUserDataDirectoryURL)
    return (true, nil)
  }
}
