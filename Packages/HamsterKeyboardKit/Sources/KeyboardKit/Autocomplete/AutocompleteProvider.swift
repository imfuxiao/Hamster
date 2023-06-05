//
//  AutocompleteProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-07-04.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public typealias AutocompleteCompletion = (AutocompleteResult) -> Void

public typealias AutocompleteResult = Result<[AutocompleteSuggestion], Error>

/**
 This protocol can be implemented by any classes that can be
 used to give autocomplete suggestions as the user types.

 该协议可以由任何可用于在用户键入时提供自动完成建议的类来实现。

 Simply call ``autocompleteSuggestions(for:completion:)`` to
 get autocomplete suggestions based on the provided text.

 只需调用 ``autocompleteSuggestions(for:completion:)`` 即可根据提供的文本获取自动完成建议。

 KeyboardKit doesn't have a standard provider as it does for
 other services. It sets up a ``DisabledAutocompleteProvider``
 that serves as a placeholder until a real one is registered.

 KeyboardKit 并不像其他服务那样有标准的提供程序。
 它会设置一个 "DisabledAutocompleteProvider"，在注册真正的提供程序之前作为一个占位符。
 */
public protocol AutocompleteProvider: AnyObject {
  /**
   The currently applied locale.
   当前应用的本地语言。
   */
  var locale: Locale { get set }

  /**
   Get autocomplete suggestions for the provided `text`.

   为提供的 `text` 获取自动完成建议。
   */
  func autocompleteSuggestions(
    for text: String,
    completion: @escaping AutocompleteCompletion
  )

  /**
   Whether or not the provider can ignore words.

   provider 是否可以忽略字词。
   */
  var canIgnoreWords: Bool { get }

  /**
   Whether or not the provider can learn words.

   provider 是否可以学习字词。
   */
  var canLearnWords: Bool { get }

  /**
   The provider's currently ignored words.

   provider 目前已忽略的字词。
   */
  var ignoredWords: [String] { get }

  /**
   The provider's currently learned words.

   provider 当前学习的字词。
   */
  var learnedWords: [String] { get }

  /**
   Whether or not the provider has ignored a certain word.

   provider 是否忽略了某个字词。
   */
  func hasIgnoredWord(_ word: String) -> Bool

  /**
   Whether or not the provider has learned a certain word.

   provider 是否学习了某个字词。
   */
  func hasLearnedWord(_ word: String) -> Bool

  /**
   Make the provider ignore a certain word.

   让 provider 忽略某个字词。
   */
  func ignoreWord(_ word: String)

  /**
   Make the provider learn a certain word.

   让 provider 学习某个字词。
   */
  func learnWord(_ word: String)

  /**
   Remove a certain ignored word from the provider.

   从 provider 中删除某个被忽略的词。
   */
  func removeIgnoredWord(_ word: String)

  /**
   Make the provider unlearn a certain word.

   让 provider 忘记已学习的某个字词
   */
  func unlearnWord(_ word: String)
}
