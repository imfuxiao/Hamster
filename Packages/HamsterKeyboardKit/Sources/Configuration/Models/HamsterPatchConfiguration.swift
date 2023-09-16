//
//  File.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation

/// Hamster 配置补丁
/// Hamster.custom.yaml
public struct HamsterPatchConfiguration: Codable, Hashable, CustomStringConvertible {
  public var patch: HamsterConfiguration?
}

public extension HamsterPatchConfiguration {
  var description: String {
    "patch: \(patch as Optional)"
  }
}
