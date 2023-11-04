//
//  FrequentSymbolProvider.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import Foundation

/// 常用符号
protocol FrequentSymbolProvider: SymbolProvider {
  func registerSymbol(_ symbol: Symbol)

  func reset()
}
