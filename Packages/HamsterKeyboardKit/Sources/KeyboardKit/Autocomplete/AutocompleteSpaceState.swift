//
//  AutocompleteSpaceState.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-03-19.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum represents the state a text document proxy can be
 in, when inserting and removing spaces during autocomplete.

 该枚举表示 ``textDocumentProxy`` 在自动完成过程中插入和删除空格时可能处于的状态。
 */
public enum AutocompleteSpaceState {
  /// This means that the proxy is not in a certain state.
  ///
  /// 这意味着代理不处于某种状态。
  case none

  /// This means that the proxy has an auto-inserted space.
  ///
  /// 这意味着代理有一个自动插入的空格。
  case autoInserted

  /// This means that the proxy has an auto-removed space.
  ///
  /// 这意味着代理有一个自动删除的空格。
  case autoRemoved
}
