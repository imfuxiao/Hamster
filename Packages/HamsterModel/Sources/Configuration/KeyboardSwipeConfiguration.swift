//
//  KeyboardSwipeConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 键盘划动配置
public struct KeyboardSwipeConfiguration: Codable, Equatable, Hashable {
  /// x 轴划动灵敏度
  public var xAxleSwipeSensitivity: Int?

  /// y 轴划动灵敏度
  public var yAxleSwipeSensitivity: Int?

  /// 空格移动光标划动灵敏度
  public var spaceSwipeSensitivity: Int?
}

