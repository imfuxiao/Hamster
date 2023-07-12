//
//  MostRecentSymbolProvider.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import Foundation

class MostRecentSymbolProvider: FrequentSymbolProvider {
  /**
   Create an instance of the provider.
   
   - Parameters:
     - maxCount: The max number of emojis to remember.
     - defaults: The store used to persist emojis.
   */
  public init(
    maxCount: Int = 30,
    defaults: UserDefaults = .hamsterSettingsDefault
  ) {
    self.maxCount = maxCount
    self.defaults = defaults
  }
  
  private let defaults: UserDefaults
  private let maxCount: Int
  private let key = "app.keyboard.mostRecentSymbolProvider.symbol"
  private static let common = ["，", "。", "？", "！"]
  
  var symbols: [Symbol] {
    symbolChars.map { Symbol(char: $0) }
  }
  
  var symbolChars: [String] {
    defaults.stringArray(forKey: key) ?? Self.common
  }
  
  func registerSymbol(_ symbol: Symbol) {
    var symbols = self.symbols.filter { $0.char != symbol.char }
    symbols.insert(symbol, at: 0)
    let result = Array(symbols.prefix(maxCount))
    let chars = result.map { $0.char }
    defaults.set(chars, forKey: key)
  }
  
  func rest() {
    defaults.set(Self.common, forKey: key)
  }
}
