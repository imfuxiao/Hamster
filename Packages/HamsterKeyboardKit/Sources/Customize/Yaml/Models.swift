//
//  Models.swift
//
//
//  Created by morse on 2023/9/1.
//

import Foundation
import HamsterKit
import OSLog

public struct Keyboards: Codable, Equatable {
  public var keyboards: [Keyboard]
}

/// 键盘
public struct Keyboard: Codable, Equatable {
  public var name: String
  // 注意：自定义键盘类型统一为 .custom() 类型
  public var type: KeyboardType
  public var rows: [Row]

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.type = .custom(named: self.name)
    self.rows = try container.decode([Row].self, forKey: .rows)
  }

  public enum CodingKeys: CodingKey {
    case name
    case rows
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.rows, forKey: .rows)
  }
}

/// 键盘的行
public struct Row: Codable, Equatable {
  public var keys: [Key]
}

/// 键盘按键
public struct Key: Codable, Equatable, Hashable {
  /// 按键对应操作
  /// 必须
  public var action: KeyboardAction

  /// 按键宽度
  /// 可选。默认为 input
  public var width: KeyWidth

  /// 按键显示文本
  /// 可选，如果不设置此值，则使用 action 对应的文本显示
  public var label: KeyLabel

  /// 是否经过 RIME 引擎处理
  /// 可选，默认值为 true
  public var processByRIME: Bool

  /// 按键划动配置
  /// 可选
  public var swipe: [KeySwipe]

  // MARK: - Initialization

  public init(action: KeyboardAction, width: KeyWidth = .input, label: KeyLabel = .empty, processByRIME: Bool = true, swipe: [KeySwipe] = []) {
    self.action = action
    self.width = width
    self.label = label
    self.processByRIME = processByRIME
    self.swipe = swipe
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let action = try? container.decode(String.self, forKey: .action), let keyboardAction = action.keyboardAction {
      self.action = keyboardAction
    } else {
      throw "action is empty"
    }

    if let width = try? container.decode(String.self, forKey: .width), let keyWidth = width.keyWidth {
      self.width = .init(portrait: keyWidth, landscape: keyWidth)
    } else if let width = try? container.decode(KeyWidth.self, forKey: .width) {
      self.width = width
    } else {
      self.width = .input
    }

    if let label = try? container.decode(String.self, forKey: .label) {
      self.label = KeyLabel(loadingText: "", text: label)
    } else if let label = try? container.decode(KeyLabel.self, forKey: .label) {
      self.label = label
    } else {
      self.label = .empty
    }

    if let processByRIME = try? container.decode(Bool.self, forKey: .processByRIME) {
      self.processByRIME = processByRIME
    } else {
      self.processByRIME = true
    }

    if let swipe = try? container.decode([KeySwipe].self, forKey: .swipe) {
      self.swipe = swipe
    } else {
      self.swipe = []
    }

    // 占位键重置属性
    if self.action.isSpacer {
      self.width = .available
      self.label = .empty
    }
  }

  enum CodingKeys: CodingKey {
    case action
    case width
    case label
    case processByRIME
    case swipe
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.action.yamlString, forKey: .action)
    try container.encode(self.width, forKey: .width)
    try container.encode(self.label, forKey: .label)
    try container.encode(self.processByRIME, forKey: .processByRIME)
    try container.encode(self.swipe, forKey: .swipe)
  }

  /// Key 显示的文本
  public var labelText: String {
    if !label.text.isEmpty { return label.text }
    return action.labelText
  }
}

/// 按键划动
public struct KeySwipe: Codable, Hashable {
  /// 按键划动方向
  public enum Direction: String, Codable, Hashable {
    case up
    case down
    // TODO: 暂不开启左右划动
    // case left
    // case right
  }

  /// 划动方向, up / down 两个方向
  /// 必须
  public var direction: Direction

  /// 操作
  /// 必须，同 key 的 action 配置
  public var action: KeyboardAction

  /// 是否由 RIME 处理
  /// 可选，默认值为 false
  public var processByRIME: Bool

  /// 是否在按键上显示
  /// 可选，默认值为 false
  public var display: Bool

  /// 显示文本
  /// 可选，如果为空，则使用 action 对应文本显示
  public var label: KeyLabel

  public init(direction: Direction, action: KeyboardAction, processByRIME: Bool = true, display: Bool = true, label: KeyLabel) {
    self.direction = direction
    self.action = action
    self.processByRIME = processByRIME
    self.display = display
    self.label = label
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let direction = try? container.decode(Direction.self, forKey: .direction) {
      self.direction = direction
    } else {
      throw "KeySwipe direction is error"
    }

    if let action = try? container.decode(String.self, forKey: .action), let keyboardAction = action.keyboardAction {
      self.action = keyboardAction
    } else {
      throw "swipe action is empty"
    }

    if let processByRIME = try? container.decode(Bool.self, forKey: .processByRIME) {
      self.processByRIME = processByRIME
    } else {
      self.processByRIME = false
    }

    if let display = try? container.decode(Bool.self, forKey: .display) {
      self.display = display
    } else {
      self.display = true
    }

    if let label = try? container.decode(String.self, forKey: .label) {
      self.label = KeyLabel(loadingText: "", text: label)
    } else if let label = try? container.decode(KeyLabel.self, forKey: .label) {
      self.label = label
    } else {
      self.label = .empty
    }
  }

  enum CodingKeys: CodingKey {
    case direction
    case action
    case processByRIME
    case display
    case label
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.direction, forKey: .direction)
    try container.encode(self.action.yamlString, forKey: .action)
    try container.encode(self.processByRIME, forKey: .processByRIME)
    try container.encode(self.display, forKey: .display)
    try container.encode(self.label, forKey: .label)
  }

  /// UILabel 显示滑动的文本
  public var labelText: String {
    // 不在添加 display 判断，请在显示前自行判断
    // guard display else { return nil }
    if !label.text.isEmpty { return label.text }
    return action.labelText
  }
}

/// 按键宽度
public struct KeyWidth: Codable, Hashable {
  public static let input: KeyWidth = .init(portrait: .input, landscape: .input)
  public static let available: KeyWidth = .init(portrait: .available, landscape: .available)

  /// 屏幕纵向
  public var portrait: KeyboardLayoutItemWidth

  /// 屏幕横向
  public var landscape: KeyboardLayoutItemWidth

  public init(portrait: KeyboardLayoutItemWidth, landscape: KeyboardLayoutItemWidth) {
    self.portrait = portrait
    self.landscape = landscape
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let portrait = try? container.decode(String.self, forKey: .portrait), let width = portrait.keyWidth {
      self.portrait = width
    } else {
      throw "KeyWidth portrait is empty"
    }
    if let landscape = try? container.decode(String.self, forKey: .landscape), let width = landscape.keyWidth {
      self.landscape = width
    } else {
      throw "KeyWidth landscape is empty"
    }
  }

  enum CodingKeys: CodingKey, Hashable {
    case portrait
    case landscape
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.portrait.string, forKey: .portrait)
    try container.encode(self.landscape.string, forKey: .landscape)
  }
}

public struct KeyLabel: Codable, Equatable, Hashable {
  public static let empty: KeyLabel = .init(loadingText: "", text: "")

  /// 键盘加载时显示文本
  public var loadingText: String
  /// 加载完毕后显示文本
  public var text: String

  public init(loadingText: String = "", text: String = "") {
    self.loadingText = loadingText
    self.text = text
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.loadingText = try container.decode(String.self, forKey: .loadingText)
    self.text = try container.decode(String.self, forKey: .text)
  }

  enum CodingKeys: CodingKey, Hashable {
    case loadingText
    case text
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.loadingText, forKey: .loadingText)
    try container.encode(self.text, forKey: .text)
  }
}

public extension String {
  /**
   属性解析

   将字符串中类似 character(q) 表达式，解析为元组 (character, q) 的方式

   注意:
   1. 如果()中存在嵌套，则不会递归解析。 比如: keyboardType(chinese(26)) 解析为 (keyboardType, chinese(26))
   2. 如果属性不包含()表达式，则返回属性本身，比如 shift 解析为 (shift, "")
   3. 如果属性包含不规则的表达式如 character(，则解析失败
   */
  func attributeParse() -> (String, String)? {
    let firstIndex = firstIndex(of: "(") ?? endIndex
    let lastIndex = lastIndex(of: ")") ?? endIndex

    if firstIndex == lastIndex, firstIndex == endIndex {
      return (self, "")
    }

    if (firstIndex != endIndex && lastIndex == endIndex) || (firstIndex == endIndex && lastIndex != endIndex) {
      return nil
    }

    let typeRange = startIndex ..< firstIndex
    guard lastIndex != endIndex else { return nil }
    let valueRange = index(firstIndex, offsetBy: 1) ..< lastIndex
    return (String(self[typeRange]), String(self[valueRange]))
  }

  var keyboardType: KeyboardType? {
    guard let (type, name) = self.attributeParse() else { return nil }
    switch type {
    case "alphabetic":
      return .alphabetic(.lowercased)
    case "numeric":
      return .numeric
    case "symbolic":
      return .symbolic
    case "classifySymbolic":
      return .classifySymbolic
    case "chinese":
      return .chinese(.lowercased)
    case "chineseNineGrid":
      return .chineseNineGrid
    case "numericNineGrid":
      return .numericNineGrid
    case "custom":
      if !name.isEmpty {
        return .custom(named: name)
      }
      return nil
    case "emojis":
      return .emojis
    default:
      return nil
    }
  }

  /// string 转 KeyboardAction
  /// 注意：switch 中把 type 转小写了，是因为 yaml 中有用户可能全部使用小写，所以 case 中也需要将多个单词转小写
  /// 与 KeyboardAction 的 yamlString 过程互逆
  var keyboardAction: KeyboardAction? {
    guard let (type, value) = self.attributeParse() else { return nil }
    switch type.lowercased() {
    case "backspace":
      return .backspace
    case "enter":
      return .primary(.return)
    case "shift":
      return .shift(currentCasing: .lowercased)
    case "tab":
      return .tab
    case "space":
      return .space
    case "character":
      guard !value.isEmpty else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      return .character(value)
    case "characterMargin".lowercased():
      guard !value.isEmpty else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      return .characterMargin(value)
    case "keyboardType".lowercased():
      guard !value.isEmpty else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      guard let keyboardType = value.keyboardType else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value: \(value) keyboardType is empty")
        return nil
      }
      return .keyboardType(keyboardType)
    case "symbol":
      guard !value.isEmpty else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      return .symbol(Symbol(char: value))
    case "shortCommand".lowercased():
      guard !value.isEmpty, let command = ShortcutCommand(rawValue: value) else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      return .shortCommand(command)
    case "chineseNineGrid".lowercased():
      guard !value.isEmpty else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      return .symbol(Symbol(char: value))
    default:
      return nil
    }
  }

  var keyWidth: KeyboardLayoutItemWidth? {
    guard let (type, value) = self.attributeParse() else { return nil }
    switch type.lowercased() {
    case "available":
      return .available
    case "input":
      return .input
    case "inputPercentage".lowercased():
      if let percent = Double(value) {
        return .inputPercentage(CGFloat(percent))
      }
      return nil
    case "percentage":
      if let percent = Double(value) {
        return .percentage(CGFloat(percent))
      }
      return nil
    case "points":
      if let percent = Double(value) {
        return .points(CGFloat(percent))
      }
      return nil
    default:
      return nil
    }
  }
}

public extension KeyboardType {
  var yamlString: String {
    switch self {
    case .alphabetic:
      return "alphabetic"
    case .numeric:
      return "numeric"
    case .symbolic:
      return "symbolic"
    case .chinese:
      return "chinese"
    case .chineseNineGrid:
      return "chineseNineGrid"
    case .numericNineGrid:
      return "numericNineGrid"
    case .classifySymbolic:
      return "classifySymbolic"
    case .emojis:
      return "emojis"
    case .custom(let name):
      return "custom(\(name))"
    default:
      return ""
    }
  }
}

public extension KeyboardAction {
  var labelText: String {
    switch self {
    case .character(let char): return char.uppercased()
    case .symbol(let symbol): return symbol.char
    case .emoji(let emoji): return emoji.char
    case .emojiCategory(let cat): return cat.fallbackDisplayEmoji.char
    case .keyboardType(let type): return type.yamlString
    case .primary: return "回车"
    case .space: return "空格"
    case .returnLastKeyboard: return "返回"
    case .chineseNineGrid(let symbol): return symbol.char
    case .cleanSpellingArea: return "重输"
    case .delimiter: return "分词"
    case .shortCommand(let command): return command.text
    default: return ""
    }
  }

  /// KeyboardAction 转 yaml 中对应配置
  /// 与 var keyboardAction: KeyboardAction? 的过程互逆
  /// 注意新增类型在这两处都要做改造
  var yamlString: String {
    switch self {
    case .backspace:
      return "backspace"
    case .primary:
      return "enter"
    case .shift:
      return "shift"
    case .tab:
      return "tab"
    case .space:
      return "space"
    case .character(let char):
      return "character(\(char))"
    case .characterMargin(let char):
      return "characterMargin(\(char))"
    case .keyboardType(let type):
      return "keyboardType(\(type.yamlString))"
    case .symbol(let symbol):
      return "symbol(\(symbol.char))"
    case .shortCommand(let command):
      return "shortCommand(\(command.rawValue))"
    case .chineseNineGrid(let symbol):
      return "chineseNineGrid(\(symbol.char))"
    default:
      return ""
    }
  }
}

public extension KeyboardLayoutItemWidth {
  var string: String {
    switch self {
    case .available:
      return "available"
    case .input:
      return "input"
    case .inputPercentage(let percent):
      return "inputPercentage(\(percent))"
    case .percentage(let percent):
      return "percentage(\(percent))"
    case .points(let value):
      return "points(\(value))"
    }
  }
}
