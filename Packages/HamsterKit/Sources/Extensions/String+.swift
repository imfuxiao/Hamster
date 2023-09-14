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

public extension String {
  func t9ToPinyin(comment: String) -> String {
    guard !comment.isEmpty else { return self.replacingOccurrences(of: " ", with: "'") }
    // 没有大写的模糊音需要替换则返回
    guard !self.filter({ $0.isUppercase }).isEmpty else { return self.replacingOccurrences(of: " ", with: "'") }

    /// 按空格拆分音节并反转，因为需要从后向前替换用户输入的 T9 编码
    let pinyinList = comment.split(separator: " ").map { String($0) }.reversed().map { String($0).lowercased() }
    let t9pinyinList = pinyinList.map { pinyinToT9Mapping[$0] ?? $0 }

    /// 字符串反转后可以从0开始替换
    var inputKey = String(self.replacingOccurrences(of: " ", with: "").reversed())
    var replaceInputKey = ""
    for (index, t9pinyin) in t9pinyinList.enumerated() {
      inputKey = inputKey.trimmingCharacters(in: .whitespaces)

      // 注意反转
      var reversedT9pinyin = String(t9pinyin.reversed())
      var reversedPinyin = String(pinyinList[index].reversed())

      // 完全包含前缀字符，则 inputKey 删除前缀，并在 newInputKey 使用 pinyin 作为 t9 的替换
      if inputKey.hasPrefix(reversedT9pinyin) {
        inputKey.removeFirst(reversedPinyin.count)
        replaceInputKey.append(reversedPinyin + " ")
        continue
      }

      // 不完全包含，则需要循环删除T9字符，已部分匹配
      while !reversedT9pinyin.isEmpty {
        _ = reversedT9pinyin.removeFirst()
        _ = reversedPinyin.removeFirst()

        if inputKey.hasPrefix(reversedT9pinyin) {
          inputKey.removeFirst(reversedPinyin.count)
          replaceInputKey.append(reversedPinyin + " ")
          break
        }
      }
    }
    if inputKey.isEmpty {
      return String(replaceInputKey.trimmingCharacters(in: .whitespaces).reversed()).replacingOccurrences(of: " ", with: "'")
    }
    return String((replaceInputKey.trimmingCharacters(in: .whitespaces) + " " + inputKey.trimmingCharacters(in: .whitespaces))
      .reversed())
      .trimmingCharacters(in: .whitespaces)
      .replacingOccurrences(of: " ", with: "'")
  }
}
