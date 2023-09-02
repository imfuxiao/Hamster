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
  public func isMatch(regex: String) -> Bool {
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
  
  /// 是否包含中文及全角符号
  public var isMatchChineseParagraph: Bool {
    isMatch(regex: Self.ChineseParagraph)
  }
  
  public var isPairSymbolsBegin: Bool {
    Self.ChinesePairSymbols.contains(self)
  }
}

extension String {
  
  /// 中文及全角标点符号(字符)
  public static let ChineseParagraph: String = "[\\u3000-\\u301e\\ufe10-\\ufe19\\ufe30-\\ufe44\\ufe50-\\ufe6b\\uff01-\\uffee]"
  public static let ChinesePairSymbols: String = "（【｛《“"

}
