//
//  String+.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-03.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension String {
  /**
   Split the string into a list of individual characters.

   将字符串分割成单个字符的List。
   */
  var chars: [String] {
    map(String.init)
  }

  func split(by separators: [String]) -> [String] {
    let separators = CharacterSet(charactersIn: separators.joined())
    return components(separatedBy: separators)
  }

  func trimming(_ set: CharacterSet) -> String {
    trimmingCharacters(in: set)
  }
}
