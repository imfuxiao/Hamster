//
//  FileBrowserViewModel.swift
//
//
//  Created by morse on 2023/7/12.
//

import Combine
import HamsterKit
import OSLog
import ProgressHUD
import UIKit

public class FileBrowserViewModel {
  // MARK: properties

  private let rootURL: URL
  public let enableEditorState: Bool

  @Published
  public var pathStack: [String] = []

  @Published
  public var files: [FileInfo] = []

  private var path: String {
    "/" + pathStack.joined(separator: "/")
  }

  private var subscriptions = Set<AnyCancellable>()

  // MARK: methods

  init(rootURL: URL, enableEditorState: Bool = true) {
    self.rootURL = rootURL
    self.enableEditorState = enableEditorState

    self.files = currentPathFiles()

    $pathStack
      .receive(on: DispatchQueue.global())
      .sink { [unowned self] _ in
        self.files = currentPathFiles()
      }
      .store(in: &subscriptions)
  }

  func currentPathFiles() -> [FileInfo] {
    do {
      let urls = try FileManager.default.contentsOfDirectory(
        at: rootURL.appendingPathComponent(pathStack.joined(separator: "/")),
        includingPropertiesForKeys: [.fileResourceTypeKey, .isDirectoryKey, .contentModificationDateKey],
        options: [.skipsHiddenFiles]
      )
      // 按字母顺序排序, 文件夹优先
      let filesInfo = urls.sorted(by: {
        let firstIsDirectory = (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        let secondIsDirectory = (try? $1.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        // 同是文件夹，则按字母排序
        if firstIsDirectory, secondIsDirectory {
          return $0.lastPathComponent < $1.lastPathComponent
        }
        // 1是文件夹，2是文件，则不需排序
        if firstIsDirectory, !secondIsDirectory {
          return true
        }
        // 2是文件夹，1是文件，则需要排序
        if secondIsDirectory, !firstIsDirectory {
          return false
        }
        // 都是文件则按字母顺序排序
        return $0.lastPathComponent < $1.lastPathComponent
      })
      .map {
        let resourceValues = try? $0.resourceValues(forKeys: [.fileResourceTypeKey, .contentModificationDateKey])
        return FileInfo(
          url: $0,
          fileResourceType: resourceValues?.fileResourceType,
          fileModifiedDate: resourceValues?.contentModificationDate
        )
      }
      return pathStack.isEmpty ? filesInfo : [FileInfo(url: URL(string: "..")!, fileResourceType: .directory, fileModifiedDate: nil)] + filesInfo
    } catch {
      Logger.statistics.error("FinderView currentURL get error: \(error.localizedDescription)")
      return []
    }
  }

  func deleteFile(fileInfo: FileInfo) {
    try? FileManager.default.removeItem(at: fileInfo.url)
    files = currentPathFiles()
  }
}
