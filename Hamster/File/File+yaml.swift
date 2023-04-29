//
//  File+yaml.swift
//  HamsterApp
//
//  Created by morse on 28/4/2023.
//

import Foundation
import Yams

extension FileManager {
  // 用来获取*.schema.yaml中的schema_id值
  func getSchemaIds(_ urls: [URL]) -> Set<String> {
    var schemaIds: Set<String> = []

    for url in urls {
      if let yamlContent = getStringFromFile(at: url) {
        do {
          if let yamlFileContent = try Yams.load(yaml: yamlContent) as? [String: Any],
             let schemaContent = yamlFileContent["schema"] as? [String: Any],
             let schemaId = schemaContent["schema_id"] as? String
          {
            schemaIds.insert(schemaId)
          }
        } catch {
          Logger.shared.log.error("yaml load error \(error.localizedDescription)")
        }
      }
    }
    return schemaIds
  }

  func mergePatchSchemaList(_ yamlURL: URL, schemaIds: [String]) -> String? {
    guard let yamlContent = getStringFromFile(at: yamlURL) else {
      Logger.shared.log.error("get yaml content is nil. url = \(yamlURL)")
      return nil
    }

    guard var yamlFileContent = try? Yams.load(yaml: yamlContent) as? [String: Any] else {
      Logger.shared.log.error("load yaml error. url = \(yamlURL)")
      return nil
    }

    var mergeSchemaIds = Set<String>(schemaIds)
    if var patch = yamlFileContent["patch"] as? [String: Any] {
      if let fileSchemaIds = patch["schema_list"] as? [Any] {
        for schemaId in fileSchemaIds {
          if let id = schemaId as? String {
            if !mergeSchemaIds.contains(id) {
              mergeSchemaIds.insert(id)
            }
          }
        }
      }
      patch["schema_list"] = Array(mergeSchemaIds)
      yamlFileContent["patch"] = patch
    } else {
      yamlFileContent["patch"] = ["schema_list": Array(mergeSchemaIds)]
    }
    return try? Yams.dump(object: yamlFileContent)
  }

  // default.custom.yaml 文件补丁
  // 补丁内容为SchemaList
  func patchOfSchemaList(_ schemaIds: [String]) -> String? {
    do {
      return try Yams.dump(object: ["patch": ["schema_list": schemaIds]])
    } catch {
      Logger.shared.log.error(error)
      return nil
    }
  }
}
