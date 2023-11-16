//
//  GeneralConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 应用通用配置
public struct GeneralConfiguration: Codable, Hashable {
  /// 启用iCloud
  public var enableAppleCloud: Bool?

  /// 拷贝文件过滤使用的正则表达式
  /// "^.*[.]userdb.*$", "^.*[.]txt$"
  /// 使用场景
  /// 1. iCloud 功能中，拷贝应用文件至 iCloud
  /// 2. 当开启 iCloud 功能后，在 RIME 每次部署时，拷贝 iCloud 中文件至应用沙盒目录
  public var regexOnCopyFile: [String]?

  /// 编辑器：是否换行
  public var textEditorLineWrappingEnabled: Bool?

  public init(enableAppleCloud: Bool? = nil, regexOnCopyFile: [String]? = nil, textEditorLineWrappingEnabled: Bool? = nil) {
    self.enableAppleCloud = enableAppleCloud
    self.regexOnCopyFile = regexOnCopyFile
    self.textEditorLineWrappingEnabled = textEditorLineWrappingEnabled
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.enableAppleCloud = try container.decodeIfPresent(Bool.self, forKey: .enableAppleCloud)
    self.regexOnCopyFile = try container.decodeIfPresent([String].self, forKey: .regexOnCopyFile)
    self.textEditorLineWrappingEnabled = try container.decodeIfPresent(Bool.self, forKey: .textEditorLineWrappingEnabled)
  }

  enum CodingKeys: CodingKey {
    case enableAppleCloud
    case regexOnCopyFile
    case textEditorLineWrappingEnabled
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.enableAppleCloud, forKey: .enableAppleCloud)
    try container.encodeIfPresent(self.regexOnCopyFile, forKey: .regexOnCopyFile)
    try container.encodeIfPresent(self.textEditorLineWrappingEnabled, forKey: .textEditorLineWrappingEnabled)
  }
}
