//
//  Models.swift
//
//
//  Created by morse on 2023/9/1.
//

import HamsterKit
import OSLog
import UIKit

public struct Keyboards: Codable, Hashable {
  public var keyboards: [Keyboard]

  public init(keyboards: [Keyboard]) {
    self.keyboards = keyboards
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.keyboards = try container.decode([Keyboard].self, forKey: .keyboards)
  }

  enum CodingKeys: CodingKey {
    case keyboards
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.keyboards, forKey: .keyboards)
  }
}

/// 自定义键盘类型
public struct Keyboard: Codable, Hashable {
  public var name: String

  /// 键盘类型
  /// 注意：此属性不包含在 yaml 配置中，因为 Keyboard 本身就是自定义键盘模型
  /// 所以自定义键盘类型统一为 .custom(name) 类型，name 对应属性 name 的值
  public var type: KeyboardType

  /// 是否是主键盘类型，用于点击符号返回主键盘功能，默认值为 false
  public var isPrimary: Bool

  /// 键盘行高度
  /// 如果为 nil, 则使用系统标准键盘行高度
  public var rowHeight: RowHeight? = nil

  /// 按钮 insets
  /// 如果为 nil, 则使用系统标准按钮 insets
  public var buttonInsets: UIEdgeInsets? = nil

  public var rows: [Row]

  public init(name: String, type: KeyboardType, isPrimary: Bool = true, rowHeight: RowHeight? = nil, buttonInsets: UIEdgeInsets? = nil, rows: [Row]) {
    self.name = name
    self.type = type
    self.isPrimary = isPrimary
    self.rowHeight = rowHeight
    self.buttonInsets = buttonInsets
    self.rows = rows
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.type = .custom(named: self.name)
    self.rows = try container.decode([Row].self, forKey: .rows)

    if let isPrimary = try? container.decodeIfPresent(Bool.self, forKey: .isPrimary) {
      self.isPrimary = isPrimary
    } else {
      self.isPrimary = false
    }

    if let rowHeight = try? container.decodeIfPresent(CGFloat.self, forKey: .rowHeight) {
      self.rowHeight = RowHeight(portrait: rowHeight, landscape: rowHeight)
    } else if let rowHeight = try? container.decodeIfPresent(RowHeight.self, forKey: .rowHeight) {
      self.rowHeight = rowHeight
    }

    if let buttonInsets = try? container.decode(String.self, forKey: .buttonInsets), let insets = self.parserUIEdgeInsets(buttonInsets) {
      self.buttonInsets = insets
    }
  }

  /// 将字符串转为 UIEdgeInsets
  /// 字符串支持两种格式
  /// 格式1: 纯数字
  /// 格式2: left(1),right(3),top(4),bottom(6)
  /// 格式 2 可以选择只配置单个方向，其余方向如果没有值则为0，方向顺序不限制，但表达式必须是：方向(值)
  func parserUIEdgeInsets(_ str: String) -> UIEdgeInsets? {
    if let value = Double(str) {
      return UIEdgeInsets.all(CGFloat(value))
    }

    let attributes = str
      .split(separator: ",")
      .compactMap { String($0).attributeParse() }

    guard !attributes.isEmpty else { return nil }

    var insets = UIEdgeInsets.zero
    for (edge, value) in attributes {
      guard let value = Double(value) else { continue }
      let v = CGFloat(value)
      switch edge {
      case "left": insets.left = v
      case "right": insets.right = v
      case "top": insets.top = v
      case "bottom": insets.bottom = v
      default: continue
      }
    }
    return insets
  }

  public enum CodingKeys: CodingKey {
    case name
    case isPrimary
    case rows
    case rowHeight
    case buttonInsets
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.isPrimary, forKey: .isPrimary)
    try container.encode(self.rows, forKey: .rows)
    if let rowHeight = self.rowHeight {
      try container.encode(rowHeight, forKey: .rowHeight)
    }
    if let buttonInsets = self.buttonInsets {
      try container.encode(buttonInsets.yamlString, forKey: .buttonInsets)
    }
  }
}

/// 键盘的行
public struct Row: Codable, Hashable {
  /// 键盘行高度
  /// 如果为 nil, 则使用系统标准键盘行高度
  public var rowHeight: RowHeight?

  public var keys: [Key]

  public init(rowHeight: RowHeight? = nil, keys: [Key]) {
    self.rowHeight = rowHeight
    self.keys = keys
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let rowHeight = try? container.decodeIfPresent(CGFloat.self, forKey: .rowHeight) {
      self.rowHeight = RowHeight(portrait: rowHeight, landscape: rowHeight)
    } else if let rowHeight = try? container.decodeIfPresent(RowHeight.self, forKey: .rowHeight) {
      self.rowHeight = rowHeight
    }

    self.keys = try container.decode([Key].self, forKey: .keys)
  }

  enum CodingKeys: CodingKey {
    case rowHeight
    case keys
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if let rowHeight = self.rowHeight {
      try container.encodeIfPresent(rowHeight, forKey: .rowHeight)
    }
    try container.encode(self.keys, forKey: .keys)
  }
}

/// 键盘按键
public struct Key: Codable, Hashable {
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

    if let action = try? container.decode(String.self, forKey: .action) {
      if let keyboardAction = action.keyboardAction {
        self.action = keyboardAction
      } else {
        throw "action: \(action) to KeyboardAction is error."
      }
    } else {
      throw "action is empty."
    }

    if let width = try? container.decode(String.self, forKey: .width), let keyWidth = width.keyWidth {
      self.width = .init(portrait: keyWidth, landscape: keyWidth)
    } else if let width = try? container.decode(KeyWidth.self, forKey: .width) {
      self.width = width
    } else {
      // 占位键如果没有设置宽度，则为 available, 其他类型默认为 input 类型宽度
      if self.action.isSpacer {
        self.width = .available
        self.label = .empty
      } else {
        self.width = .input
      }
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
  public enum Direction: String, Codable, Hashable, CaseIterable, Comparable {
    case up
    case down
    case left
    case right

    public var labelText: String {
      switch self {
      case .up: return "上划"
      case .down: return "下划"
      case .left: return "左划"
      case .right: return "右划"
      }
    }

    public var value: Int {
      switch self {
      case .up: 4
      case .down: 3
      case .left: 2
      case .right: 1
      }
    }

    public static func < (lhs: KeySwipe.Direction, rhs: KeySwipe.Direction) -> Bool {
      lhs.value < rhs.value
    }
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
  /// 可选，默认值为 true
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

    if let action = try? container.decode(String.self, forKey: .action) {
      if let keyboardAction = action.keyboardAction {
        self.action = keyboardAction
      } else {
        throw "swipe \(action) to action is error"
      }
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

/// 行高
public struct RowHeight: Codable, Hashable {
  /// 屏幕纵向高度
  public var portrait: CGFloat

  /// 屏幕横向高度
  public var landscape: CGFloat

  public init(portrait: CGFloat, landscape: CGFloat) {
    self.portrait = portrait
    self.landscape = landscape
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.portrait = try container.decode(CGFloat.self, forKey: .portrait)
    self.landscape = try container.decode(CGFloat.self, forKey: .landscape)
  }

  enum CodingKeys: CodingKey {
    case portrait
    case landscape
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.portrait, forKey: .portrait)
    try container.encode(self.landscape, forKey: .landscape)
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

public struct KeyLabel: Codable, Hashable {
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
      // 注意：value == "#繁简切换" 为补丁
      guard !value.isEmpty else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      let command = ShortcutCommand(rawValue: value == "#繁简切换" ? "#简繁切换" : value)
      return .shortCommand(command)
    case "chineseNineGrid".lowercased():
      guard !value.isEmpty else {
        Logger.statistics.error("\(self) keyboardAction type: \(type), value is empty")
        return nil
      }
      return .chineseNineGrid(Symbol(char: value))
    case "none": return KeyboardAction.none
    case "nextKeyboard".lowercased(): return KeyboardAction.nextKeyboard
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
    case .custom(let name, _):
      return "custom(\(name))"
    default:
      return ""
    }
  }

  var labelText: String {
    switch self {
    case .alphabetic:
      return "ABC"
    case .numeric, .chineseNumeric, .numericNineGrid:
      return "123"
    case .symbolic, .chineseSymbolic:
      return "#+="
    case .classifySymbolic:
      return "符"
    case .chinese, .chineseNineGrid, .custom:
      return "中"
    case .emojis:
      return "􀎸"
    default:
      return ""
    }
  }
}

public extension KeyboardAction {
  var labelText: String {
    switch self {
    case .character(let char): return char
    case .symbol(let symbol): return symbol.char
    case .emoji(let emoji): return emoji.char
    case .emojiCategory(let cat): return cat.fallbackDisplayEmoji.char
    case .keyboardType(let type): return type.labelText
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
    case .none:
      return "none"
    case .nextKeyboard:
      return "nextKeyboard"
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

extension UIEdgeInsets: Hashable {
  /// 为 UIEdgeInsets 类型添加 Hashable 协议支持
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.top)
    hasher.combine(self.left)
    hasher.combine(self.bottom)
    hasher.combine(self.right)
  }

  /// 输出 yaml 中配置格式
  var yamlString: String {
    return "left(\(self.left)),right(\(self.right)),top(\(self.top)),bottom(\(self.bottom))"
  }
}
