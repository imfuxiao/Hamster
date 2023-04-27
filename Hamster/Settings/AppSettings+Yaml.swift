//
//  AppSettings+Yaml.swift
//  Hamster
//
//  Created by morse on 26/4/2023.
//

import Foundation
import Yams

extension HamsterAppSettings {
  // default.custom.yaml 文件补丁
  // 补丁内容为SchemaList
  var defaultFilePatchOfSchemaList: String? {
    do {
      return try Yams.dump(object: ["patch": ["schema_list": rimeUserSelectSchema.map { $0.schemaId }]])
    } catch {
      Logger.shared.log.error(error)
      return nil
    }
  }
}
