//
//  KeyboardType.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-05-18.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum contains all keyboard types that can currently be
 bound to the `KeyboardAction` switch keyboard action.

 此 enum 包含当前可绑定到 `KeyboardAction` 切换 keyboard action 的所有键盘类型。

 If you need a keyboard type that is not represented here or
 that is app-specific, you can use `.custom`.
 */
public enum KeyboardType: Codable, Identifiable, Hashable {
  /**
   `.alphabetic` represents keyboards that have alphabetic
   input keys for the current locale.

   `.alphabetic` 表示在当前语言环境下具有字母输入键的键盘。

   This type can be created with a ``SystemKeyboard``, but
   you can create custom alphabetic keyboards as well.

   这种类型可以用``SystemKeyboard``创建，但也可以创建自定义字母键盘。
   */
  case alphabetic(KeyboardCase)

  /**
   `.numeric` represents keyboards that have numeric input
   keys for the current locale.

   `.numeric` 代表在当前语言环境下有数字输入键的键盘。

   This type can be created with a ``SystemKeyboard``, but
   you can create custom numeric keyboards as well.

   这种类型可以用``SystemKeyboard``创建，但也可以创建自定义数字键盘。
   */
  case numeric

  /**
   `.symbolic` represents keyboards that have symbol input
   keys for the current locale.

   `.symbolic` 代表在当前语言环境下具有符号输入键的键盘。

   This type can be created with a ``SystemKeyboard``, but
   you can create custom symbolic keyboards as well.

   这种类型可以用``SystemKeyboard``创建，但也可以创建自定义符号键盘。
   */
  case symbolic

  /**
   `.email` represents keyboards that have e-mail specific
   input keys for the current locale.

   `.email` 代表在当前语言环境下具有 email 特定输入键的键盘。

   KeyboardKit has no built-in view for this keyboard type,
   so if you want to use it, you must create your own.

   KeyboardKit 没有为这种键盘类型内置 view，因此如果要使用它，必须创建自己的 view。
   */
  case email

  /**
   `.emoji` represents keyboards that either present emoji
   characters or emoji categories.

   `.emoji` 表示显示 emoji 字符或 emoji 类别的键盘。

   This type can be rendered with the ``EmojiKeyboard`` or
   the ``EmojiCategoryKeyboard`` views, but you can create
   custom emoji keyboards as well.

   这种类型可通过 ``EmojiKeyboard`` 或 ``EmojiCategoryKeyboard`` view 显示，但也可以创建自定义表情符号键盘。
   */
  case emojis

  /**
   `.image` represents keyboards that present custom image
   buttons with custom handing.

   `.image` 代表带有自定义处理的自定义图像按钮的键盘。

   KeyboardKit has no built-in view for this keyboard type,
   so if you want to use it, you must create your own.

   KeyboardKit 没有为这种键盘类型内置 view，因此如果要使用它，必须创建自己的 view。
   */
  case images

  /**
   `.custom` can be used to indicate that keyboards should
   use an entirely custom type.

   `.custom` 可用来表示键盘应使用完全自定义的类型。
   */
  case custom(named: String, case: KeyboardCase = .lowercased)

  /**
   中文全键盘
   */
  case chinese(KeyboardCase)

  /// 中文数字全键
  case chineseNumeric

  /// 中文符号全键
  case chineseSymbolic

  /**
   中文九宫格
   */
  case chineseNineGrid

  /**
   数字九宫格
   */
  case numericNineGrid

  /**
   分类符号键
   */
  case classifySymbolic

  /**
   （白色）分类符号键盘
   */
  case classifySymbolicOfLight

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .alphabetic(let casing): hasher.combine("alphabetic(\(casing.rawValue))")
    case .numeric: hasher.combine("numeric")
    case .symbolic: hasher.combine("symbolic")
    case .email: hasher.combine("email")
    case .emojis: hasher.combine("emojis")
    case .images: hasher.combine("images")
    case .custom(let name, let casing): hasher.combine("custom(name:\(name), case:\(casing.rawValue))")
    case .chinese(let casing): hasher.combine("chinese(\(casing.rawValue))")
    case .chineseNumeric: hasher.combine("chineseNumeric")
    case .chineseSymbolic: hasher.combine("chineseSymbolic")
    case .chineseNineGrid: hasher.combine("chineseNineGrid")
    case .numericNineGrid: hasher.combine("numericNineGrid")
    case .classifySymbolic: hasher.combine("classifySymbolic")
    case .classifySymbolicOfLight: hasher.combine("classifySymbolicOfLight")
    }
  }
}

public extension KeyboardType {
  /**
   The type's unique identifier.

   KeyboardType的唯一标识符。
   */
  var id: String {
    switch self {
    case .alphabetic(let casing): return casing.id
    case .numeric: return "numeric"
    case .symbolic: return "symbolic"
    case .email: return "email"
    case .emojis: return "emojis"
    case .images: return "images"
    case .custom(let name, let casing): return "custom_\(name)_\(casing.id)"
    case .chinese(let casing): return "chinese_\(casing.id)"
    case .chineseNineGrid: return "chineseNineGrid"
    case .numericNineGrid: return "numericNineGrid"
    case .classifySymbolic: return "classifySymbolic"
    case .classifySymbolicOfLight: return "classifySymbolicOfLight"
    case .chineseNumeric: return "chineseNumeric"
    case .chineseSymbolic: return "chineseSymbolic"
    }
  }

  /**
   Whether or not the keyboard type is alphabetic.

   键盘类型是否为 alphabetic 类型。
   */
  var isAlphabetic: Bool {
    switch self {
    case .alphabetic: return true
    default: return false
    }
  }

  /// 是否中文键盘
  var isChinese: Bool {
    switch self {
    case .chinese: return true
    case .chineseNineGrid: return true
    case .chineseNumeric: return true
    case .chineseSymbolic: return true
    default:
      return false
    }
  }

  /// 是否自定义键盘
  var isCustom: Bool {
    switch self {
    case .custom: return true
    default:
      return false
    }
  }

  /**
   该键盘类型是否为 custom 类型，是否具有特定的 shift 状态。
   */
  func isCustom(_ case: KeyboardCase) -> Bool {
    switch self {
    case .custom(_, let current): return current == `case`
    default: return false
    }
  }

  /// 是否数字键盘
  var isNumber: Bool {
    switch self {
    case .numeric: return true
    case .numericNineGrid: return true
    case .chineseNumeric: return true
    default:
      return false
    }
  }

  /// 是否符号键盘
  var isSymbol: Bool {
    switch self {
    case .symbolic: return true
    case .chineseSymbolic: return true
    default: return false
    }
  }

  /// 是否中文九宫格键盘
  var isChineseNineGrid: Bool {
    switch self {
    case .chineseNineGrid: return true
    default:
      return false
    }
  }

  /// 是否数字九宫格键盘
  var isNumberNineGrid: Bool {
    switch self {
    case .numericNineGrid: return true
    default:
      return false
    }
  }

  /// 是否是中文主键盘（即输入中文的键盘，不包含数字及符号）
  var isChinesePrimaryKeyboard: Bool {
    switch self {
    case .chinese: return true
    default:
      return false
    }
  }

  /**
   该键盘类型是否为 chinese 类型，是否具有特定的 shift 状态。
   */
  func isChinesePrimaryKeyboard(_ case: KeyboardCase) -> Bool {
    switch self {
    case .chinese(let current): return current == `case`
    default: return false
    }
  }

  /// 显示按键气泡的键盘类型
  var displayButtonBubbles: Bool {
    switch self {
    case .chinese: return true
    case .alphabetic: return true
    case .custom: return true
    default:
      return false
    }
  }

  /**
   Whether or not this keyboard type is alphabetic and has
   an uppercased or capslocked shift state.

   该键盘类型是否为 alphabetic 类型，是否具有大写或大写锁定 shift 状态。
   */
  var isAlphabeticUppercased: Bool {
    switch self {
    case .alphabetic(let current): return current.isUppercased
    default: return false
    }
  }

  /**
   Whether or not this keyboard type is alphabetic and has
   a certain shift state.

   该键盘类型是否为 alphabetic 类型，是否具有特定的 shift 状态。
   */
  func isAlphabetic(_ case: KeyboardCase) -> Bool {
    switch self {
    case .alphabetic(let current): return current == `case`
    default: return false
    }
  }
}
