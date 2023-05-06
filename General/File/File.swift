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

  static func createDirectory(override: Bool = false, dst: URL) throws {
    let fm = FileManager.default
    if fm.fileExists(atPath: dst.path) {
      if override {
        try fm.removeItem(atPath: dst.path)
      } else {
        return
      }
    }
    try fm.createDirectory(at: dst, withIntermediateDirectories: true, attributes: nil)
  }

  static func copyDirectory(override: Bool = false, src: URL, dst: URL) throws {
    let fm = FileManager.default
    if fm.fileExists(atPath: dst.path) {
      if override {
        try fm.removeItem(atPath: dst.path)
      } else {
        return
      }
    }

    if !fm.fileExists(atPath: dst.deletingLastPathComponent().path) {
      try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
    }
    try fm.copyItem(at: src, to: dst)
  }

  /// 增量复制
  /// 增量是指文件名相同且内容相同的文件会跳过，如果是目录，则会比较目录下的内容
  /// filterRegex: 正则表达式，用来过滤复制的文件，true: 需要过滤
  /// filterMatchBreak: 匹配后是否跳过 true 表示跳过匹配文件, 只拷贝非匹配的文件 false 表示只拷贝匹配文件
  static func incrementalCopy(src: URL, dst: URL, filterRegex: [String] = [], filterMatchBreak: Bool = true, override: Bool = true) throws {
    let fm = FileManager.default
    // 递归获取全部文件
    guard let srcFiles = fm.enumerator(at: src, includingPropertiesForKeys: [.isDirectoryKey]) else { return }
    guard let dstFiles = fm.enumerator(at: dst, includingPropertiesForKeys: [.isDirectoryKey]) else { return }

    let dstFilesMapping = dstFiles.allObjects.compactMap { $0 as? URL }.reduce(into: [String: URL]()) { $0[$1.path.replacingOccurrences(of: dst.path, with: "")] = $1 }
    let srcPrefix = src.path

    while let file = srcFiles.nextObject() as? URL {
      
      // 正则过滤: true 表示正则匹配成功，false 表示没有匹配正则
      let match = !(filterRegex.first(where: { file.path.isMatch(regex: $0) }) ?? "" ).isEmpty
      
      // 匹配且需要跳过匹配项, 这是过滤的默认行为
      if match && filterMatchBreak {
        Logger.shared.log.debug("filter filterRegex: \(filterRegex), filterMatchBreak: \(filterMatchBreak), file: \(file.path)")
        continue
      }
      
      // 不匹配且设置了不跳过匹配项，这是反向过滤行为，即只copy匹配过滤项文件
      if !filterRegex.isEmpty && !match && !filterMatchBreak {
        Logger.shared.log.debug("filter filterRegex: \(filterRegex), match: \(match), filterMatchBreak: \(filterMatchBreak), file: \(file.path)")
        continue
      }
      
      Logger.shared.log.debug("incrementalCopy src: \(src.path) dst: \(dst.path), file: \(file.path)")

      let isDirectory = (try? file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
      let relativePath = file.path.hasPrefix(srcPrefix) ? file.path.replacingOccurrences(of: srcPrefix, with: "") : file.path.replacingOccurrences(of: "/private" + srcPrefix, with: "")

      let dstFile = dstFilesMapping[relativePath] ?? dst.appendingPathComponent(relativePath, isDirectory: isDirectory)

      if fm.fileExists(atPath: dstFile.path) {
        // 目录不比较内容
        if isDirectory {
          continue
        }

        if fm.contentsEqual(atPath: file.path, andPath: dstFile.path) {
          continue // 文件已存在, 且内容相同，跳过
        }

        if override {
          try fm.removeItem(at: dstFile)
        }
      }

      if !fm.fileExists(atPath: dstFile.deletingLastPathComponent().path) {
        try FileManager.createDirectory(dst: dstFile.deletingLastPathComponent())
      }

      if isDirectory {
        try FileManager.createDirectory(dst: dstFile)
        continue
      }

      Logger.shared.log.debug("incrementalCopy copy file: \(file.path) dst: \(dstFile.path)")
      try fm.copyItem(at: file, to: dstFile)
    }
  }
}

extension String {
  func isMatch(regex: String) -> Bool {
    if #available(iOS 16, *) {
      Logger.shared.log.debug("isMatch #available(iOS 16, *)")
      guard let r = try? Regex(regex) else { return false }
      return self.contains(r)
    } else {
      Logger.shared.log.debug("isMatch use NSRegularExpression")
      guard let regex = try? NSRegularExpression(pattern: regex) else { return false }
      // 这使用utf16计数，以避免表情符号和类似的问题。
      let range = NSRange(location: 0, length: utf16.count)
      return regex.firstMatch(in: self, range: range) != nil
    }
  }
}
