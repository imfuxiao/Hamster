//
//  GeneralConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 应用通用配置
public struct GeneralConfiguration: Codable, Equatable, Hashable {
  /// 启用iCloud
  public var enableAppleCloud: Bool?

  /// 拷贝文件过滤使用的正则表达式
  /// "^.*[.]userdb.*$", "^.*[.]txt$"
  /// 使用场景
  /// 1. iCloud 功能中，拷贝应用文件至 iCloud
  /// 2. 当开启 iCloud 功能后，在 RIME 每次部署时，拷贝 iCloud 中文件至应用沙盒目录
  public var regexOnCopyFile: [String]?
}
