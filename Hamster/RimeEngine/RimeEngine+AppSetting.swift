//
//  RimeEngine+AppSetting.swift
//  Hamster
//
//  Created by morse on 26/4/2023.
//

import Foundation

extension RimeEngine {
  // 注意：调用此方案必须先启动RimeEngine
  func initAppSettingRimeInputSchema(_ appSettings: HamsterAppSettings) {
    let schemas = getSchemas().sorted()

    if !appSettings.rimeUserSelectSchema.isEmpty, !appSettings.rimeInputSchema.isEmpty {
      // 需要判断是选择的输入方案否存在当前方案，如果不存在，则需要重新
      if !appSettings.rimeUserSelectSchema.contains(where: { $0.schemaId == appSettings.rimeInputSchema }) {
        if let first = schemas.first(where: { $0.schemaId == appSettings.rimeInputSchema }) {
          appSettings.rimeUserSelectSchema = [first]
          let handled = setSelectRimeSchemas(schemas: [first])
          Logger.shared.log.info("initAppSettingRimeInputSchema setSelectRimeSchemas handled \(handled)")
        }
      }
      return
    }

    // 当前输入方案不为空，而用户选择方案为空，则使用当前方案作为用户选择方案
    if !appSettings.rimeInputSchema.isEmpty, appSettings.rimeUserSelectSchema.isEmpty {
      if let first = schemas.first(where: { $0.schemaId == appSettings.rimeInputSchema }) {
        appSettings.rimeUserSelectSchema = [first]
        let handled = setSelectRimeSchemas(schemas: [first])
        Logger.shared.log.info("initAppSettingRimeInputSchema setSelectRimeSchemas handled \(handled)")
      }
      return
    }

    // 当用户选择方案不为空，当前方案为空，则赋值排序后的第一个值
    if !appSettings.rimeUserSelectSchema.isEmpty, appSettings.rimeInputSchema.isEmpty {
      appSettings.rimeInputSchema = appSettings.rimeUserSelectSchema.first!.schemaId
      return
    }

    // 都为空时，取排序后的第一个
    if appSettings.rimeUserSelectSchema.isEmpty, appSettings.rimeInputSchema.isEmpty {
      appSettings.rimeInputSchema = schemas.first?.schemaId ?? ""
      appSettings.rimeUserSelectSchema = schemas.first != nil ? [schemas.first!] : []
      if !appSettings.rimeUserSelectSchema.isEmpty {
        let handled = setSelectRimeSchemas(schemas: schemas)
        Logger.shared.log.info("initAppSettingRimeInputSchema setSelectRimeSchemas handled \(handled)")
      }
      return
    }
  }
}
