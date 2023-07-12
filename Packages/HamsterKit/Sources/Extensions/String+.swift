//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation

/// Easily throw generic errors with a text description.
extension String: LocalizedError {
  public var errorDescription: String? {
    return self
  }
}

extension String {
  func isMatch(regex: String) -> Bool {
    if #available(iOS 16, *) {
      guard let r = try? Regex(regex) else { return false }
      return self.contains(r)
    } else {
      guard let regex = try? NSRegularExpression(pattern: regex) else { return false }
      // 这使用utf16计数，以避免表情符号和类似的问题。
      let range = NSRange(location: 0, length: utf16.count)
      return regex.firstMatch(in: self, range: range) != nil
    }
  }
}
