//
//  KeyboardSwipeConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 键盘划动配置
public struct KeyboardSwipeConfiguration: Codable, Hashable {
  public typealias KeySwipeMapping = [KeyboardAction: [KeySwipe]]

  // 空格移动光标的灵敏度，指移动多个个点，光标移动一位。
  public var spaceDragSensitivity: Int?

  /// 划动距离阈值，当划动的距离大于或等于此值时，才会识别为一次划动
  public var distanceThreshold: Int?

  // 此值是正切角度的阈值，用来限制上下左右划动时的角度，如果太大容易误触
  // 默认为 15 度的正切值，即上下左右划的的角度不能超过 15 度
  // tan(10º) ≈ 0.176, tan(15º) ≈ 0.268, tan(30º) ≈ 0.577, tan(45º) = 1, tan(60º) ≈ 1.732
  public var tangentThreshold: CGFloat?

  // 长按延迟时间，只要大于或等于此阈值，才会触发长按 Action，如空格划动
  public var longPressDelay: Double?

  /// 内置键盘滑动配置
  public var keyboardSwipe: [KeyboardSwipe]?

  /// 内置键盘滑动配置
  public private(set) var keyboardSwipeMapping: [KeyboardType: KeySwipeMapping] = [:]

  public init(spaceDragSensitivity: Int? = nil, distanceThreshold: Int? = nil, tangentThreshold: CGFloat? = nil, longPressDelay: Double? = nil, keyboardSwipe: [KeyboardSwipe]? = nil) {
    self.spaceDragSensitivity = spaceDragSensitivity
    self.distanceThreshold = distanceThreshold
    self.tangentThreshold = tangentThreshold
    self.longPressDelay = longPressDelay
    self.keyboardSwipe = keyboardSwipe
    self.keyboardSwipeMapping = keyboardSwipeToMap(keyboardSwipe)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.spaceDragSensitivity = try container.decodeIfPresent(Int.self, forKey: .spaceDragSensitivity)
    self.distanceThreshold = try container.decodeIfPresent(Int.self, forKey: .distanceThreshold)
    self.tangentThreshold = try container.decodeIfPresent(CGFloat.self, forKey: .tangentThreshold)
    self.longPressDelay = try container.decodeIfPresent(Double.self, forKey: .longPressDelay)
    self.keyboardSwipe = try container.decodeIfPresent([KeyboardSwipe].self, forKey: .keyboardSwipe)
    self.keyboardSwipeMapping = keyboardSwipeToMap(keyboardSwipe)
  }

  enum CodingKeys: CodingKey {
    case spaceDragSensitivity
    case distanceThreshold
    case tangentThreshold
    case longPressDelay
    case keyboardSwipe
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.spaceDragSensitivity, forKey: .spaceDragSensitivity)
    try container.encodeIfPresent(self.distanceThreshold, forKey: .distanceThreshold)
    try container.encodeIfPresent(self.tangentThreshold, forKey: .tangentThreshold)
    try container.encodeIfPresent(self.longPressDelay, forKey: .longPressDelay)
    try container.encodeIfPresent(self.keyboardSwipe, forKey: .keyboardSwipe)
  }

  private func keyboardSwipeToMap(_ keyboardSwipe: [KeyboardSwipe]?) -> [KeyboardType: KeySwipeMapping] {
    var result = [KeyboardType: KeySwipeMapping]()
    for ks in keyboardSwipe ?? [] {
      if let keyboardType = ks.keyboardType, let keys = ks.keys {
        var keySwipeMap: KeySwipeMapping = [:]
        for key in keys {
          keySwipeMap[key.action] = key.swipe
        }
        result[keyboardType] = keySwipeMap
      }
    }
    return result
  }
}

/// 内置键盘滑动配置
/// 注意：自定义键盘滑动配置在自定义键盘的配置文件中
public struct KeyboardSwipe: Codable, Hashable {
  public var keyboardType: KeyboardType?
  public var keys: [Key]?

  public init(keyboardType: KeyboardType, keys: [Key]) {
    self.keyboardType = keyboardType
    self.keys = keys
  }

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
