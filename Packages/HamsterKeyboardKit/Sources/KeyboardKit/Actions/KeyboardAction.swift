//
//  KeyboardAction.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2018-02-02.
//  Copyright © 2018-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This enum defines keyboard-specific actions that correspond
 to actions that can be found on various keyboards.
 
 Keyboard actions can be bound to buttons and triggered with
 a ``KeyboardActionHandler``. Keyboard actions are also used
 to define keyboard layouts and provide a declarative way to
 express a keyboard layout without having to specify exactly
 how your actions will be executed.

 The documentation for each action type describes the type's
 standard behavior, if any. Types that don't have a standard
 behavior require a custom ``KeyboardActionHandler``.
 
 该枚举定义了键盘特定的操作，这些操作与各种键盘上的操作相对应。
 
 KeyboardAction 可绑定到按钮，并使用 ``KeyboardActionHandler`` 触发。
 
 KeyboardAction 还可用于定义键盘布局，并提供一种声明式方法来表达键盘布局，而无需明确指定操作的执行方式。
 
 每种 Action 类型的文档都描述了该类型的标准行为（如果有的话）。没有标准行为的类型需要自定义 ``KeyboardActionHandler`` 。
 */
public enum KeyboardAction: Codable, Equatable {
  /// Deletes backwards when pressed, and repeats until released.
  /// 按下时向后删除，重复按下直至松开。
  case backspace
  
  /// Inserts a text character when released.
  /// 释放时插入一个文本字符。
  case character(String)
  
  /// Inserts a text character when released, but is rendered as empty space.
  /// 释放时插入一个文本字符，但UI显示为空白。
  case characterMargin(String)
  
  /// Represents a command (⌘) key.
  /// 代表 Command (⌘) 键。
  case command
  
  /// Represents a control (⌃) key.
  /// 代表 Control (⌃) 键。
  case control

  /// A custom action that you can handle in any way you want.
  /// 自定义操作，您可以随意处理。
  case custom(named: String)
  
  /// Represents a dictation key.
  /// 代表听写键。
  case dictation
  
  /// Dismisses the keyboard when released.
  /// 松开后关闭键盘。
  case dismissKeyboard
  
  /// Inserts an emoji when released.
  /// 释放时插入一个表情符号。
  case emoji(Emoji)
  
  /// Can be used to show a specific emoji category.
  /// 可用于显示特定的表情符号类别。
  case emojiCategory(EmojiCategory)
  
  /// Represents an escape (esc) key.
  /// 代表 Esc 键。
  case escape
  
  /// Represents a function (fn) key.
  /// 代表 Fn 键。
  case function
  
  /// Can be used to refer to an image asset.
  /// 可用于引用 image 资源。
  case image(description: String, keyboardImageName: String, imageName: String)
  
  /// Changes the keyboard type when pressed.
  /// 按下时更改键盘类型。
  case keyboardType(KeyboardType)
  
  /// Moves the input cursor back one step when released.
  /// 释放时将光标后移一步。
  case moveCursorBackward
  
  /// Moves the input cursor forward one step when released.
  /// 释放时将光标向前移动一步。
  case moveCursorForward
  
  /// Represents a keyboard switcher (🌐) button and triggers the keyboard switch action when long pressed and released.
  /// 代表键盘切换 (🌐)按钮，长按并松开时触发键盘切换操作。
  case nextKeyboard
  
  /// Triggers the locale switcher action when long pressed and released.
  /// 长按并松开时触发 local 切换操作。
  case nextLocale
  
  /// A placeholder action that does nothing and should not be rendered.
  /// 占位符(placeholder) 操作，不做任何操作且UI不应呈现。
  case none
  
  /// Represents an option (⌥) key.
  /// 代表 Option (⌥)键。
  case option
  
  /// Represents a primary return button, e.g. `return`, `go`, `search` etc.
  /// 代表 Return 按钮，如 "返回"、"前往"、"搜索 "等。
  case primary(KeyboardReturnKeyType)
  
  /// A custom action that can be used to e.g. show a settings screen.
  /// 自定义操作，可用于显示设置界面等。
  case settings
  
  /// Changes the keyboard type to `.alphabetic(.uppercased)` when released and `.capslocked` when double tapped.
  /// 释放时将键盘类型更改为".alphabetic(.uppercased)"，双击时更改为".capslocked"。
  case shift(currentCasing: KeyboardCase)
  
  /// Inserts a space when released and moves the cursor when long pressed.
  /// 释放时插入空格，长按时移动光标。
  case space
  
  /// Can be used to refer to a system image (SF Symbol).
  /// 可用于指代系统 image（如 SF 符号）。
  case systemImage(description: String, keyboardImageName: String, imageName: String)

  /// Open system settings for the app when released.
  /// 释放后打开应用程序的设置页面。
  case systemSettings
  
  /// Inserts a tab when released.
  /// 释放时插入一个 Tab 符号。
  case tab

  /// Open an url when released, using a custom id for identification.
  /// 释放时打开一个 url，使用自定义 ID 进行标识。
  case url(_ url: URL?, id: String? = nil)
  
  /// 插入一个符号
  case symbol(Symbol)
}

// MARK: - Public Extensions

public extension KeyboardAction {
  /**
   Whether or not the action is an alphabetic type.
   
   操作是否为字母类型。
   */
  var isAlphabeticKeyboardTypeAction: Bool {
    switch self {
    case .keyboardType(let type): return type.isAlphabetic
    default: return false
    }
  }
    
  /**
   Whether or not the action is a character action.
   
   该操作是否属于字符类型。
   */
  var isCharacterAction: Bool {
    switch self {
    case .character: return true
    default: return false
    }
  }

  /**
   Whether or not the action is an emoji action.
   
   操作是否为表情符号类型。
   */
  var isEmojiAction: Bool {
    switch self {
    case .emoji: return true
    default: return false
    }
  }
    
  /**
   Whether or not the action is an input action.
   
   该操作是否为输入操作。

   An input action inserts content into the text proxy and
   is by default rendered as a light button.
   
   输入操作指将输入的内容插入 TextProxy，默认情况下呈现为一个浅色按钮。
   */
  var isInputAction: Bool {
    switch self {
    case .character: return true
    case .characterMargin: return true
    case .emoji: return true
    case .image: return true
    case .space: return true
    case .systemImage: return true
    default: return false
    }
  }
  
  /**
   显示按键气泡
   */
  var showKeyBubble: Bool {
    switch self {
    case .character: return true
    default: return false
    }
  }
    
  /**
   Whether or not the action is a primary action.
   
   该操作是否为 primary 操作。

   Primary actions always insert a new line into the proxy,
   but can be rendered in various ways. For instance, most
   primary actions will by default use a blue color, while
   `.return` and `.newLine` are rendered as system buttons.
   
   primary 操作总是在 textProxy 中插入新行，但按钮可以以各种方式呈现。
   例如，大多数 primary 操作默认使用蓝色，而 `.return` 和 `.newLine` 则呈现为系统按钮。
   */
  var isPrimaryAction: Bool {
    switch self {
    case .primary: return true
    default: return false
    }
  }
    
  /**
   Whether or not the action is a shift action.
   
   该操作是否为 shift 操作。
   */
  var isShiftAction: Bool {
    switch self {
    case .shift: return true
    default: return false
    }
  }

  /**
   Whether or not the action primary serves as a spacer.
   
   该操作是否用作间隔器(spacer)。
   */
  var isSpacer: Bool {
    switch self {
    case .characterMargin: return true
    case .none: return true
    default: return false
    }
  }
    
  /**
   Whether or not the action is a system action, which the
   library by default renders as darker buttons.
   
   该操作是否为系统操作，默认情况下将其渲染为较暗颜色的按钮。
   */
  var isSystemAction: Bool {
    switch self {
    case .backspace: return true
    case .command: return true
    case .control: return true
    case .dictation: return true
    case .dismissKeyboard: return true
    case .emojiCategory: return true
    case .escape: return true
    case .function: return true
    case .keyboardType: return true
    case .moveCursorBackward: return true
    case .moveCursorForward: return true
    case .nextKeyboard: return true
    case .nextLocale: return true
    case .option: return true
    case .primary(let type): return type.isSystemAction
    case .shift: return true
    case .settings: return true
    case .tab: return true
    default: return false
    }
  }
    
  /**
   Whether or not the action is an uppercase shift action.
   
   该操作是否为大写 shift 操作。
   */
  var isUppercasedShiftAction: Bool {
    switch self {
    case .shift(let state): return state.isUppercased
    default: return false
    }
  }

  /**
   Whether or not the action is a keyboard type action.
   
   该操作是否为键盘类型操作。
   */
  func isKeyboardTypeAction(_ keyboardType: KeyboardType) -> Bool {
    switch self {
    case .keyboardType(let type): return type == keyboardType
    default: return false
    }
  }
}
