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

public extension String {
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

public extension StringProtocol {
  func t9ToPinyin(comment: String) -> String {
    let pinyinList = comment.split(separator: " ")
    let t9pinyinList = pinyinList.map { pinyinToT9Mapping[String($0)] ?? String($0) }

    // rime 返回格式可能缺失音节切分
    var inputKey = replacingOccurrences(of: " ", with: "")

    // 按T9拆分 inputKey
    for (index, t9pinyin) in t9pinyinList.enumerated() {
      if inputKey.contains(t9pinyin), let startIndex = inputKey.index(of: t9pinyin) {
        let endIndex = inputKey.index(startIndex, offsetBy: t9pinyin.count)
        inputKey.replaceSubrange(startIndex ..< endIndex, with: endIndex == inputKey.endIndex ? pinyinList[index] : pinyinList[index] + "'")
      } else {
        let startIndex: String.Index
        if let firstIndex = inputKey.lastIndex(of: "'") {
          startIndex = inputKey.index(firstIndex, offsetBy: 1)
        } else {
          startIndex = inputKey.startIndex
        }
        let range = startIndex ..< inputKey.endIndex
        let pinyin = pinyinList[index].prefix(inputKey[range].count)
        inputKey.replaceSubrange(range, with: pinyin)
      }
    }
    return inputKey
  }
}
