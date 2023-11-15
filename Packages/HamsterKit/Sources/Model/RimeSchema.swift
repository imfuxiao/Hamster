//
//  RimeSchema.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// RIME 输入方案
public struct RimeSchema: Identifiable, Equatable, Hashable, Comparable, Codable {
  public var id: String
  public var schemaId: String
  public var schemaName: String

  public init(schemaId: String, schemaName: String) {
    self.id = schemaId
    self.schemaId = schemaId
    self.schemaName = schemaName
  }
}

public extension RimeSchema {
  static func < (lhs: RimeSchema, rhs: RimeSchema) -> Bool {
    lhs.schemaId <= rhs.schemaId
  }

  static func == (lhs: RimeSchema, rhs: RimeSchema) -> Bool {
    return lhs.schemaId == rhs.schemaId
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(schemaId)
  }
}
