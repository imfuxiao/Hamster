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
  public var Keyboard: KeyboardConfiguration?

  /// RIME 配置
  public var rime: RimeConfiguration?

  /// 划动配置
  public var swipe: KeyboardSwipeConfiguration?

  public init(
    general: GeneralConfiguration? = nil,
    toolbar: KeyboardToolbarConfiguration? = nil,
    Keyboard: KeyboardConfiguration? = nil,
    rime: RimeConfiguration? = nil,
    swipe: KeyboardSwipeConfiguration? = nil)
  {
    self.general = general
    self.toolbar = toolbar
    self.Keyboard = Keyboard
    self.rime = rime
    self.swipe = swipe
  }
}

public extension HamsterConfiguration {
  /// 合并 HamsterConfiguration
  /// 利用JSON序列化的api做合并逻辑
  /// uniquingKeysWith: 合并中当键相同时，使用那个值。$1 表示 使用 with 的值
  func merge(with: HamsterConfiguration, uniquingKeysWith conflictResolver: (Any, Any) throws -> Any) throws -> HamsterConfiguration {
    let encoder = JSONEncoder()
    let selfData = try encoder.encode(self)
    let withData = try encoder.encode(with)

    var selfDict = try JSONSerialization.jsonObject(with: selfData) as! [String: Any]
    let withDict = try JSONSerialization.jsonObject(with: withData) as! [String: Any]

    try selfDict.merge(withDict, uniquingKeysWith: conflictResolver)

    let final = try JSONSerialization.data(withJSONObject: selfDict)
    return try JSONDecoder().decode(HamsterConfiguration.self, from: final)
  }
}

public extension HamsterConfiguration {
  var description: String {
    "{ general: \(general as Optional),\n toolbar: \(toolbar as Optional), \n keyboard: \(Keyboard as Optional), \n rime: \(rime as Optional) }"
  }
}
