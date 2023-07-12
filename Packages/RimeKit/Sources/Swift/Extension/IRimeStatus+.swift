//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation
@_exported import RimeKitObjC

extension IRimeStatus {
  func currentSchema() -> RimeSchema {
    RimeSchema(schemaId: self.schemaId == nil ? "" : self.schemaId, schemaName: self.schemaName == nil ? "" : self.schemaName)
  }
}
