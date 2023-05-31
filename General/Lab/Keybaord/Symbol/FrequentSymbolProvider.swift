//
//  FrequentSymbolProvider.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import Foundation

/// 常用符号
protocol FrequentSymbolProvider: SymbolProvider {
  /**
   Register that a symbol has been used. This will be used
   to prepare the symbols that will be returned by `symbols`.
   */
  func registerSymbol(_ symbol: Symbol)

  func rest()
}
