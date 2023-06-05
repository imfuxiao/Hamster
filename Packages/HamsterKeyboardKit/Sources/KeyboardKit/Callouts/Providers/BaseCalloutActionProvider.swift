//
//  BaseCalloutActionProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This base class provides functionality to simplify creating
 a callout action provider.
 
 该基类提供了简化创建呼出操作 provider 的功能。
 
 You can inherit this class and override any open properties
 and functions to customize the callout actions. The easiest
 way is to override `calloutActionString(for:)` and return a
 string that is then split and mapped to keyboard actions by
 `calloutActions(for:)`.
 
 您可以继承该类并覆盖任何 open 属性和函数，以自定义呼出操作。
 最简单的方法是覆盖 `calloutActionString(for:)` 函数，并返回一个字符串，
 然后由 `calloutActions(for:)`分割并映射到键盘操作。
 
 ``EnglishCalloutActionProvider`` uses this logic to specify
 which actions to use for basic English.
 
 ``EnglishCalloutActionProvider`` 使用此逻辑来指定基本英语要使用的操作。
 */
open class BaseCalloutActionProvider: CalloutActionProvider {
  public init() throws {}
    
  /**
   Get callout actions for the provided `action`.
   
   为提供的 `action` 获取呼出操作。
     
   These actions are presented in a callout when a user is
   long pressing this action.
   
   当用户长按该 action 时，这些操作会在呼出中显示。
   */
  open func calloutActions(for action: KeyboardAction) -> [KeyboardAction] {
    switch action {
    case .character(let char): return calloutActions(for: char)
    default: return []
    }
  }
    
  /**
   Get callout actions for the provided `char`.
   
   获取所提供的 `char` 的呼出操作。
     
   These actions are presented in a callout when a user is
   long pressing this character.
   
   当用户长按该字符时，这些操作会在呼出中显示。
   */
  open func calloutActions(for char: String) -> [KeyboardAction] {
    let charValue = char.lowercased()
    let result = calloutActionString(for: charValue)
    let string = char.isUppercased ? result.uppercased() : result
    return string.map { .character(String($0)) }
  }
    
  /**
   Get callout actions as a string for the provided `char`.
   
   以字符串形式获取所提供的 `char` 的呼出操作。

   You can override this function if you want to customize
   the string that by default will be split into a list of
   ``KeyboardAction``s by `calloutActions(for:)`.
   
   如果要自定义字符串，可以重载此函数，
   默认情况下，字符串会被 `calloutActions(for:)` 分割为一系列键盘操作。

   Note that you must override `calloutActions(for:)` when
   these actions must support multuple multiple characters,
   e.g. for `kr` currencies, or when you want to use other
   action types than just characters.
   
   请注意，如果这些操作必须支持多个字符（例如，对于 `kr` 货币），
   或者如果您想使用其他操作类型（而不仅仅是字符），则必须重载 `calloutActions(for:)`。
   */
  open func calloutActionString(for char: String) -> String { "" }
}
