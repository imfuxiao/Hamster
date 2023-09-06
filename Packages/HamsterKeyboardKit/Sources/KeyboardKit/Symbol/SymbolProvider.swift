//
//  SymbolProvider.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import Foundation

protocol SymbolProvider {
  /**
   The symbols being returned by the provider.
   */
  var symbols: [Symbol] { get }
}
