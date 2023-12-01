//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation
import OSLog

/// Easily throw generic errors with a text description.
extension String: LocalizedError {
  public var errorDescription: String? {
    return self
  }
}

public extension String {
  var containsChineseCharacters: Bool {
    return self.range(of: "\\p{Han}", options: .regularExpression) != nil
  }

  // 低效率版本
//  var containsChineseCharacters: Bool {
//    var result = false
//    for c in self {
//      let cs = String(c)
//      if let newCS = cs.applyingTransform(.mandarinToLatin, reverse: false), newCS != cs {
//        result = true
//        break
//      }
//    }
//    return result
//  }

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

  /// 是否包含中文及全角符号
  var isMatchChineseParagraph: Bool {
    isMatch(regex: Self.ChineseParagraph)
  }

  var isPairSymbolsBegin: Bool {
    Self.ChinesePairSymbols.contains(self)
  }
}

public extension String {
  /// 中文及全角标点符号(字符)
  static let ChineseParagraph: String = "[\\u3000-\\u301e\\ufe10-\\ufe19\\ufe30-\\ufe44\\ufe50-\\ufe6b\\uff01-\\uffee]"
  static let ChinesePairSymbols: String = "（【｛《“"
}

public extension StringProtocol {
  // 查找子串 index
  func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
    range(of: string, options: options)?.lowerBound
  }

  func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
    range(of: string, options: options)?.upperBound
  }

  func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
    ranges(of: string, options: options).map(\.lowerBound)
  }

  func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
    var result: [Range<Index>] = []
    var startIndex = self.startIndex
    while startIndex < endIndex,
          let range = self[startIndex...]
          .range(of: string, options: options)
    {
      result.append(range)
      startIndex = range.lowerBound < range.upperBound ? range.upperBound :
        index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
    }
    return result
  }
}

public extension String {
  var replaceT9pinyin: String {
    map {
      let key = String($0)
      if let pinYinList = t9ToPinyinMapping[key] {
        return pinYinList[0]
      }
      return key
    }
    .joined()
  }

  func t9pinyinToPinyin(comment: String, separator: String = "'") -> String {
    guard !comment.isEmpty else { return replaceT9pinyin }
    // 拆分音节
    let commentList = comment
      .split(separator: " ")
      .map { String($0) }

    // 将 comment 拼音转 t9 数字编码，用来对字符串中的 t9 做转换
    let t9CommentList = commentList
      .compactMap { pinyinToT9Mapping[$0] ?? $0 }

    var previewList = split(separator: " ").map { String($0) }
    for (index, t9pinyin) in t9CommentList.enumerated() {
      if index < previewList.count {
        if previewList[index].count >= t9pinyin.count {
          previewList[index] = previewList[index].replacingOccurrences(of: t9pinyin, with: commentList[index])
        } else {
          previewList[index] = String(commentList[index].prefix(previewList[index].count))
        }
      }
    }

    return previewList.joined(separator: separator)
  }
}
