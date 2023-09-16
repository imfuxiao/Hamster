//
//  RimeConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// RIME 偏好设置
public struct RimeConfiguration: Codable, Hashable {
  /// 最大候选字数量
  public var maximumNumberOfCandidateWords: Int?

  /// 简繁切换对应的键
  public var keyValueOfSwitchSimplifiedAndTraditional: String?

  /// RIME 重新部署时，是否覆盖词库文件
  /// 如果使用自造词，需要改为 false, 否则部署时会覆盖键盘自造词文件
  public var overrideDictFiles: Bool?

  /// 覆盖词库文件的正则表达式
  /// 使用场景：
  /// 在开启 overrideDictFiles 后，每次重新部署会按照正则表达式符合的条件翻盖文件
  public var regexOnOverrideDictFiles: [String]?

  /// 拷贝键盘文件至应用沙盒目录的正则表达式，只会拷贝并覆盖符合表达式的文件。
  /// 正则表达式为空时，则使用默认值 ["^.*[.]userdb.*$", "^.*[.]txt$"]
  /// 使用场景：在文件管理功能中，拷贝键盘词库文件至应用
  public var regexOnCopyAppGroupDictFile: [String]?
}
