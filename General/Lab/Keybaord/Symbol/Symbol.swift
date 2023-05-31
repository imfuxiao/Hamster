//
//  Symbol.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import SwiftUI

struct Symbol: Equatable, Codable, Identifiable {
  init(char: String) {
    self.char = char
  }

  var id = UUID()
  var char: String
}

extension Symbol {
  /**
   Get all emojis from all categories.
   */
  static var all: [Symbol] {
    SymbolCategory.all.flatMap { $0.symbols }
  }
}

struct Symbol_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 160))], spacing: 20) {
        ForEach(Symbol.all) {
          Text($0.char)
        }
      }.padding()
    }
  }
}
