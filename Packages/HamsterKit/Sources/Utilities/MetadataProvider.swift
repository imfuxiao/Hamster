//
//  MetadataProvider.swift
//  Hamster
//
//  Created by morse on 5/5/2023.
//

import Combine
import Foundation
import OSLog

class MetadataProvider {
  private let metadataQuery = NSMetadataQuery()
  
  private(set) var containerRootURL: URL?
  private var querySubscriber: AnyCancellable?
    
  init() {
    containerRootURL = URL.iCloudDocumentURL
    
    let names: [NSNotification.Name] = [.NSMetadataQueryDidFinishGathering, .NSMetadataQueryDidUpdate]
    let publishers = names.map { NotificationCenter.default.publisher(for: $0) }
    querySubscriber = Publishers
      .MergeMany(publishers)
      .receive(on: DispatchQueue.global())
      .sink { [unowned self] notification in
        guard notification.object as? NSMetadataQuery === self.metadataQuery else { return }
        
        let items = self.metadataItemList()
        for item in items {
          try? FileManager.default.startDownloadingUbiquitousItem(at: item.url)
          Logger.statistics.debug("downloading \(item.url)")
        }
      }
    
    // 发生更新结果通知的时间间隔。1s
    metadataQuery.notificationBatchingInterval = 1
    metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope, NSMetadataQueryUbiquitousDocumentsScope]
    // TODO: 获取全部文件
    // metadataQuery.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, "*." + Document.extensionName)
    metadataQuery.predicate = NSPredicate(value: true)
    metadataQuery.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSNameKey, ascending: true)]
    metadataQuery.start()
    Logger.statistics.debug("metadataQuery start")
  }
    
  deinit {
    guard metadataQuery.isStarted else { return }
    metadataQuery.stop()
    Logger.statistics.debug("metadataQuery stop")
  }
}

// MARK: - Providing metadata items

//
extension MetadataProvider {
  // 直接从查询中提供metadataItems。为了避免潜在的冲突，在访问结果时禁用查询更新，并在完成访问后启用它。
  func metadataItemList() -> [MetadataItem] {
    var result = [MetadataItem]()
    metadataQuery.disableUpdates()
    if let metadatItems = metadataQuery.results as? [NSMetadataItem] {
      result = metadataItemList(from: metadatItems)
    }
    metadataQuery.enableUpdates()
    return result
  }
  
  // 将nsMetataItems转换成MetadataItem数组。
  // 过滤掉目录和没有有效名称的URL的。
  // 注意，从文件中查询.isDirectoryKey键会导致失败。
  private func metadataItemList(from nsMetataItems: [NSMetadataItem]) -> [MetadataItem] {
    let validItems = nsMetataItems
      .filter { item in
      
        guard let fileURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL,
              item.value(forAttribute: NSMetadataItemFSNameKey) != nil else { return false }
        
        // 文件下载状态：
        // NSMetadataUbiquitousItemDownloadingStatusCurrent 表示本地文件与iCloud文件相同
        let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String ?? ""
        guard downloadStatus != NSMetadataUbiquitousItemDownloadingStatusCurrent else { return false }
            
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .isPackageKey]
        if let resourceValues = try? (fileURL as NSURL).resourceValues(forKeys: resourceKeys),
           let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as? Bool, isDirectory,
           let isPackage = resourceValues[URLResourceKey.isPackageKey] as? Bool, !isPackage
        {
          return false
        }
        return true
      }
        
    return validItems
      .map {
        let itemURL = $0.value(forAttribute: NSMetadataItemURLKey) as? URL
        return MetadataItem(nsMetadataItem: $0, url: itemURL!)
      }
  }
}

struct MetadataItem: Hashable {
  let nsMetadataItem: NSMetadataItem?
  let url: URL
    
  static func == (lhs: MetadataItem, rhs: MetadataItem) -> Bool {
    return lhs.url.path == rhs.url.path
  }
    
  func hash(into hasher: inout Hasher) {
    hasher.combine(url.path)
  }
}
