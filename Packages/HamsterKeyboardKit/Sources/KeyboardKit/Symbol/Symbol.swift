//
//  Symbol.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import Foundation

public struct Symbol: Equatable, Codable, Identifiable, Hashable {
  public init(char: String) {
    self.char = char
  }

  public var id = UUID()
  public var char: String
}

extension Symbol {
  static var all: [Symbol] {
    SymbolCategory.all.flatMap { $0.symbols }
  }
}
