//
//  RimeEngine+LibrimeKit.swift
//  HamsterApp
//
//  Created by morse on 7/3/2023.
//

import Foundation
import LibrimeKit

extension IRimeStatus {
  func currentSchema() -> Schema {
    Schema(schemaId: self.schemaId == nil ? "" : self.schemaId, schemaName: self.schemaName == nil ? "" : self.schemaName)
  }
}
