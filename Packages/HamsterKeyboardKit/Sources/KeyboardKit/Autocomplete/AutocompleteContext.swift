//
//  ObservableAutocompleteContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-09-12.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Combine

/**
 This is an observable class that can be used to store a set
 of autocomplete suggestions.

 这是一个可观察类，可用于存储一组自动完成建议。

 KeyboardKit automatically creates an instance of this class
 and binds the created instance to the keyboard controller's
 ``KeyboardInputViewController/autocompleteContext``.

 KeyboardKit 会自动创建该类的实例，并将创建的实例绑定到键盘控制器的
 ``KeyboardInputViewController/autocompleteContext`` 中。
 */
public class AutocompleteContext: ObservableObject {
  /**
   Whether or not autocomplete is enabled.

   是否启用自动完成功能。
   */
  @Published
  public var isEnabled = true

  /**
   Whether or not suggestions are currently being fetched.

   是否正在获取建议。
   */
  @Published
  public var isLoading = false

  /**
   The last received autocomplete error.

   最后收到的自动完成的错误。
   */
  @Published
  public var lastError: Error?

  /**
   The last received autocomplete suggestions.

   最后收到的自动完成建议。
   */
  @Published
  public var suggestions: [AutocompleteSuggestion] = []

  /**
   Reset the autocomplete contexts.

   重置自动完成上下文。
   */
  public func reset() {
    isLoading = false
    lastError = nil
    suggestions = []
  }

  public init() {}
}
