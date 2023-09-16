//
//  KeyboardSwipeConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 键盘划动配置
public struct KeyboardSwipeConfiguration: Codable, Hashable {
  /// x 轴划动灵敏度
  public var xAxleSwipeSensitivity: Int?

  /// y 轴划动灵敏度
  public var yAxleSwipeSensitivity: Int?

  /// 空格移动光标划动灵敏度
  public var spaceSwipeSensitivity: Int?

  /// 内置键盘滑动配置
  public var keyboardSwipe: [KeyboardSwipe]?
}

/// 内置键盘滑动配置
/// 注意：自定义键盘滑动配置在自定义键盘的配置文件中
public struct KeyboardSwipe: Codable, Hashable {
  public var keyboardType: KeyboardType?
  public var keys: [Key]?

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let keyboardType = try container.decodeIfPresent(String.self, forKey: .keyboardType),
       let keyboardType = keyboardType.keyboardType
    {
      self.keyboardType = keyboardType
    }
    self.keys = try container.decodeIfPresent([Key].self, forKey: .keys)
  }

  enum CodingKeys: CodingKey {
    case keyboardType
    case keys
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.keyboardType?.yamlString, forKey: .keyboardType)
    try container.encodeIfPresent(self.keys, forKey: .keys)
  }
}
