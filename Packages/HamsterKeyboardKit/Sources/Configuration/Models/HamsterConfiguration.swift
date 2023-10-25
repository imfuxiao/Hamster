//
//  HamsterConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// Hamster应用全部配置项
/// Hamster.yaml
public struct HamsterConfiguration: Codable, Hashable, CustomStringConvertible {
  /// 通用配置
  public var general: GeneralConfiguration?

  /// 键盘工具栏配置
  public var toolbar: KeyboardToolbarConfiguration?

  /// 键盘配置
  public var keyboard: KeyboardConfiguration?

  /// RIME 配置
  public var rime: RimeConfiguration?

  /// 划动配置
  public var swipe: KeyboardSwipeConfiguration?

  /// 自定义键盘
  public var keyboards: [Keyboard]?

  public init(
    general: GeneralConfiguration? = nil,
    toolbar: KeyboardToolbarConfiguration? = nil,
    keyboard: KeyboardConfiguration? = nil,
    rime: RimeConfiguration? = nil,
    swipe: KeyboardSwipeConfiguration? = nil,
    keyboards: [Keyboard]? = nil
  ) {
    self.general = general
    self.toolbar = toolbar
    self.keyboard = keyboard
    self.rime = rime
    self.swipe = swipe
    self.keyboards = keyboards
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.general = try container.decodeIfPresent(GeneralConfiguration.self, forKey: .general)
    self.toolbar = try container.decodeIfPresent(KeyboardToolbarConfiguration.self, forKey: .toolbar)

    // Patch: yaml 中历史有配置 Keyboard 大写的情况
    if let keyboard = try? container.decodeIfPresent(KeyboardConfiguration.self, forKey: .Keyboard) {
      self.keyboard = keyboard
    } else if let keyboard = try? container.decodeIfPresent(KeyboardConfiguration.self, forKey: .keyboard) {
      self.keyboard = keyboard
    }

    self.rime = try container.decodeIfPresent(RimeConfiguration.self, forKey: .rime)
    self.swipe = try container.decodeIfPresent(KeyboardSwipeConfiguration.self, forKey: .swipe)
    self.keyboards = try container.decodeIfPresent([Keyboard].self, forKey: .keyboards)
  }

  enum CodingKeys: String, CodingKey {
    case general
    case toolbar
    case keyboard
    // Patch: yaml 中历史有配置 Keyboard 大写的情况
    case Keyboard
    case rime
    case swipe
    case keyboards
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.general, forKey: .general)
    try container.encodeIfPresent(self.toolbar, forKey: .toolbar)
    try container.encodeIfPresent(self.keyboard, forKey: .keyboard)
    try container.encodeIfPresent(self.rime, forKey: .rime)
    try container.encodeIfPresent(self.swipe, forKey: .swipe)
    try container.encodeIfPresent(self.keyboards, forKey: .keyboards)
  }
}

public extension HamsterConfiguration {
  /// 合并 HamsterConfiguration
  /// 利用JSON序列化的api做合并逻辑
  /// uniquingKeysWith: 合并中当键相同时，使用那个值。$1 表示 使用 with 的值
  func merge(with: HamsterConfiguration, uniquingKeysWith conflictResolver: @escaping (Any, Any) throws -> Any) throws -> HamsterConfiguration {
    let encoder = JSONEncoder()
    let selfData = try encoder.encode(self)
    let withData = try encoder.encode(with)

    var selfDict = try JSONSerialization.jsonObject(with: selfData) as! [String: Any]
    let withDict = try JSONSerialization.jsonObject(with: withData) as! [String: Any]

    selfDict = try deepMerge(selfDict, withDict, uniquingKeysWith: conflictResolver)
    // try selfDict.merge(withDict, uniquingKeysWith: conflictResolver)

    let final = try JSONSerialization.data(withJSONObject: selfDict)
    return try JSONDecoder().decode(HamsterConfiguration.self, from: final)
  }

  func deepMerge(_ d1: [String: Any], _ d2: [String: Any], uniquingKeysWith conflictResolver: @escaping (Any, Any) throws -> Any) throws -> [String: Any] {
    var result = d1
    for (k2, v2) in d2 {
      if let v1 = result[k2] as? [String: Any], let v2 = v2 as? [String: Any] {
        result[k2] = try deepMerge(v1, v2, uniquingKeysWith: conflictResolver)
      } else {
        if let v1 = d1[k2] {
          result[k2] = try conflictResolver(v1, v2)
        } else {
          result[k2] = v2
        }
      }
    }
    return result
  }
}

public extension HamsterConfiguration {
  var description: String {
    "{ general: \(general as Optional),\n toolbar: \(toolbar as Optional), \n keyboard: \(keyboard as Optional), \n rime: \(rime as Optional), keyboards: \(keyboards as Optional) }"
  }
}
