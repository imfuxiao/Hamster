//
//  Symbol.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import Foundation

public struct Symbol: Codable, Identifiable, Hashable {
  public var id: UUID
  public var char: String

  public init(id: UUID = UUID(), char: String) {
    self.id = id
    self.char = char
  }
}

extension Symbol {
  static var all: [Symbol] {
    SymbolCategory.all.flatMap { $0.symbols }
  }
}
