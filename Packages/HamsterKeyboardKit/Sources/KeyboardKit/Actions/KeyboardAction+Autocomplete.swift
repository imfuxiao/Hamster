//
//  KeyboardAction+Autocomplete.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-03-18.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension KeyboardAction {
  /**
   Whether or not the action should apply currently active
   autocomplete suggestions where `isAutocomplete` is true.

   当 `isAutocomplete` 为 true 时，是否应用当前活动的自动完成 suggestion。
   */
  var shouldApplyAutocompleteSuggestion: Bool {
    switch self {
    case .character(let char): return char.isWordDelimiter
    case .primary(let type): return type.isSystemAction
    case .space: return true
    default: return false
    }
  }

  /**
   Whether or not the action should insert an autocomplete
   removed space.

   该操作是否应插入自动完成删除的空格。
   */
  var shouldReinsertAutocompleteInsertedSpace: Bool {
    shouldRemoveAutocompleteInsertedSpace
  }

  /**
   Whether or not the action should remove an autocomplete
   inserted space.

   该操作是否应删除自动完成插入的空格。
   */
  var shouldRemoveAutocompleteInsertedSpace: Bool {
    switch self {
    case .character(let char): return char.isWordDelimiter && self != .space
    default: return false
    }
  }
}
