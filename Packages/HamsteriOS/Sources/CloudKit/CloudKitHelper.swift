//
//  CloudKitHelper.swift
//
//  CloudKit 工具类，提供对 CloudKit 数据的访问
//
//  Created by morse on 2023/11/11.
//

import CloudKit
import HamsterKit

/// CloudKit 访问工具类
class CloudKitHelper {
  typealias InputSchemaCallback = (Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) -> Void

  public static let shared = CloudKitHelper()

  private lazy var container = CKContainer(identifier: HamsterConstants.iCloudID)
  private lazy var database = container.publicCloudDatabase

  private init() {}

  /// 测试方法，向 CloudKit 添加测试数据
  public func _testInsertInputSchema() async throws {
    let database = CKContainer(identifier: HamsterConstants.iCloudID).publicCloudDatabase

    for index in 1 ... 100 {
      let record = CKRecord(recordType: Self.inputSchemaRecordTypeName)
      record.setValue("这是一个输入方案\(index)", forKey: "title")
      record.setValue("作者是\(index)", forKey: "author")
      record.setValue("这是一个输入方案的描述，描述内容是\n惺惺\n相惜惺\n惺相惜惺惺相惜惺惺相惜惺惺相惜惺惺相惜惺惺相惜惺惺相惜x", forKey: "descriptions")
      try await database.save(record)
    }
  }

  /// 获取公共库下输入方案列表
  public func inputSchemaList(_ title: String = "", callback: @escaping InputSchemaCallback) async throws {
    // 构建查询
    let predicate: NSPredicate
    if !title.isEmpty {
      predicate = NSPredicate(format: "self contains %@", title)
    } else {
      predicate = NSPredicate(value: true)
    }
    let query = CKQuery(recordType: Self.inputSchemaRecordTypeName, predicate: predicate)

    // 设置服务优先级
    let config = CKOperation.Configuration()
    config.qualityOfService = .userInitiated
    database.configuredWith(configuration: config) { db in
      db.fetch(withQuery: query, desiredKeys: Self.inputSchemaRecordDesiredKeys, resultsLimit: Self.resultLimit) { result in
        callback(result)
      }
    }
  }

  /// 根据游标查询输入方案
  public func inputSchemaListByCursor(_ cursor: CKQueryOperation.Cursor, callback: @escaping InputSchemaCallback) async throws {
    database.fetch(withCursor: cursor, desiredKeys: Self.inputSchemaRecordDesiredKeys, resultsLimit: Self.resultLimit) { result in
      callback(result)
    }
  }

  public func getRecord(id: CKRecord.ID) async throws -> CKRecord {
    return try await database.record(for: id)
  }

  public func saveRecord(_ record: CKRecord) async throws -> CKRecord {
    try await database.save(record)
  }
}

extension CloudKitHelper {
  public static let inputSchemaRecordTypeName = "InputSchemes"
  private static let inputSchemaRecordDesiredKeys = ["title", "author", "descriptions"]
  private static let resultLimit = 20
}
