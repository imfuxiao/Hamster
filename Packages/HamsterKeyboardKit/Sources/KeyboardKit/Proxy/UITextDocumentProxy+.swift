//
//  UITextDocumentProxy+.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-03-17.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

// MARK: - Quotation 引号

import UIKit

public extension UITextDocumentProxy {
  /**
   Check whether or not the last trailing quotation before
   the input cursor is an alt. quotation begin delimiter.

   检查光标前的最后一个引号是否为备用引号，且为备用引号的开头符号
   */
  func hasUnclosedAlternateQuotationBeforeInput(for locale: Locale) -> Bool {
    documentContextBeforeInput?.hasUnclosedAlternateQuotation(for: locale) ?? false
  }

  /**
   Check whether or not the last trailing quotation before
   the input cursor is a quotation begin delimiter.

   检查光标前的最后一个引号是否是引号，且为引号的开头符号。
   */
  func hasUnclosedQuotationBeforeInput(for locale: Locale) -> Bool {
    documentContextBeforeInput?.hasUnclosedQuotation(for: locale) ?? false
  }

  /**
   Check if a certain text that is about to be inserted to
   the proxy should be replaced with something else.

   检查即将插入代理的某个文本是否应替换为其他内容。
   */
  func preferredQuotationReplacement(whenInserting text: String, for locale: Locale) -> String? {
    documentContextBeforeInput?.preferredQuotationReplacement(whenAppending: text, for: locale)
  }
}

// MARK: - Sentences 句子

public extension UITextDocumentProxy {
  /**
   Check if the text input cursor is at the start of a new
   sentence, with or without trailing whitespace.

   检查光标是否位于新句子的开头，且句子尾部不带有空格
   */
  var isCursorAtNewSentence: Bool {
    documentContextBeforeInput?.isLastSentenceEnded ?? true
  }

  /**
   Check if the text input cursor is at the start of a new
   sentence, with trailing whitespace.

   检查光标是否位于新句子的开头，且句子尾部带有空格。
   */
  var isCursorAtNewSentenceWithTrailingWhitespace: Bool {
    documentContextBeforeInput?.isLastSentenceEndedWithTrailingWhitespace ?? true
  }

  /**
   The last ended sentence right before the cursor, if any.

   返回光标前最后的句子，如果存在
   */
  var sentenceBeforeInput: String? {
    documentContextBeforeInput?.lastSentence
  }

  /**
   A list of western sentence delimiters.

   西文语句的分隔符号列表

   See the ``KeyboardCharacterProvider`` documentation for
   information on how to modify this delimiter collection.

   有关如何修改分隔符列表的信息，请参阅 ``KeyboardCharacterProvider`` 文档。
   */
  var sentenceDelimiters: [String] {
    String.sentenceDelimiters
  }

  /**
   End the current sentence by removing all trailing space
   characters, then injecting a dot and a space.

   在结束当前句子时，删除所有尾部空格字符，然后注入一个句号和一个空格。
   */
  func endSentence() {
    guard isCursorAtTheEndOfTheCurrentWord else { return }
    while (documentContextBeforeInput ?? "").hasSuffix(" ") {
      deleteBackward(times: 1)
    }
    insertText(". ")
  }
}

// MARK: - Words

public extension UITextDocumentProxy {
  /**
   The word that is currently being touched by the cursor.

   获取光标周围的单词或单词片段。
   */
  var currentWord: String? {
    let pre = currentWordPreCursorPart
    let post = currentWordPostCursorPart
    if pre == nil, post == nil { return nil }
    return (pre ?? "") + (post ?? "")
  }

  /**
   The part of the current word that is before the cursor.

   光标之前的单词或单词片段
   */
  var currentWordPreCursorPart: String? {
    documentContextBeforeInput?.wordFragmentAtEnd
  }

  /**
   The part of the current word that is after the cursor.

   光标之后的单词或单词片段
   */
  var currentWordPostCursorPart: String? {
    documentContextAfterInput?.wordFragmentAtStart
  }

  /**
   Whether or not a word is currently being touched by the
   text input cursor.

   光标当前是否涉及某个单词。
   */
  var hasCurrentWord: Bool {
    currentWord != nil
  }

  /**
   Whether or not the text document proxy cursor is at the
   beginning of a new word.

   光标是否位于新单词开头位置
   */
  var isCursorAtNewWord: Bool {
    guard let pre = documentContextBeforeInput else { return true }
    let lastCharacter = String(pre.suffix(1))
    return pre.isEmpty || lastCharacter.isWordDelimiter
  }

  /**
   Whether or not the text document proxy cursor is at the
   end of the current word.

   光标是否位于单词的结尾
   */
  var isCursorAtTheEndOfTheCurrentWord: Bool {
    if currentWord == nil { return false }
    let postCount = currentWordPostCursorPart?.trimming(.whitespaces).count ?? 0
    if postCount > 0 { return false }
    guard let pre = currentWordPreCursorPart else { return false }
    let lastCharacter = String(pre.suffix(1))
    return !wordDelimiters.contains(lastCharacter)
  }

  /**
   The last ended word right before the cursor, if any.

   光标前最后一个结束的单词（如果有）。
   */
  var wordBeforeInput: String? {
    if isCursorAtNewSentence { return nil }
    guard isCursorAtNewWord else { return nil }
    guard let context = documentContextBeforeInput else { return nil }
    guard let result = context
      .split(by: wordDelimiters)
      .dropLast()
      .last?
      .trimming(.whitespaces)
    else { return nil }
    return result.isEmpty ? nil : result
  }

  /**
   A list of western word delimiters.

   西方单词分隔符列表。

   See the ``KeyboardCharacterProvider`` documentation for
   information on how to modify this delimiter collection.

   有关如何修改分隔符集合的信息，请参阅 ``KeyboardCharacterProvider`` 文档。
   */
  var wordDelimiters: [String] {
    String.wordDelimiters
  }

  /**
   Replace the current word with a replacement text.

   用给定 `replacement` 文本，替换当前单词。
   */
  func replaceCurrentWord(with replacement: String) {
    guard let word = currentWord else { return }
    let offset = currentWordPostCursorPart?.count ?? 0
    adjustTextPosition(byCharacterOffset: offset)
    deleteBackward(times: word.count)
    insertText(replacement)
  }
}

private extension UITextDocumentProxy {
  /**
   Check if a certain character should be included in the
   current word.

   给定字符`character`是否应该为西文单词的一部分
   true: 是单词的一部分
   */
  func shouldIncludeCharacterInCurrentWord(_ character: Character?) -> Bool {
    guard let character = character else { return false }
    return !wordDelimiters.contains("\(character)")
  }
}

// MARK: - Delete

public extension UITextDocumentProxy {
  /**
   Delete backwards a certain range.

   向后删除一定范围内的内容。
   */
  func deleteBackward(range: DeleteBackwardRange) {
    let count = deleteBackwardCount(for: range)
    deleteBackward(times: count)
  }

  /// 给定范围 `range`，向后删除
  func deleteBackwardCount(for range: DeleteBackwardRange) -> Int {
    switch range {
    case .character: return 1
    case .sentence: return 4
    case .word: return 2
    }
  }

  /**
   Delete backwards a certain number of times.

   向后删除一定次数。
   */
  func deleteBackward(times: Int) {
    for _ in 0 ..< times { deleteBackward() }
  }

  /// 给定范围 `range`，向后删除
  func deleteBackwardText(for range: DeleteBackwardRange) -> String? {
    guard let text = documentContextBeforeInput else { return nil }
    switch range {
    case .character: return text.lastCharacter
    case .sentence: return text.lastSentenceSegment
    case .word: return text.lastWordSegment
    }
  }
}

// MARK: - Autocomplete

public extension UITextDocumentProxy {
  /**
   Whether or not the proxy has a space before the current
   input, that has been inserted by autocomplete.

   代理是否在当前输入之前有一个空格，该空格是由自动完成插入的。
   */
  var hasAutocompleteInsertedSpace: Bool {
    ProxyState.state == .autoInserted && documentContextBeforeInput?.hasSuffix(" ") == true
  }

  /**
   Whether or not the proxy has removed a space before the
   current input, that has been inserted by autocomplete.

   代理是否删除了当前输入之前由自动完成插入的空格。
   */
  var hasAutocompleteRemovedSpace: Bool {
    ProxyState.state == .autoRemoved
  }

  /**
   Replace the current word in the proxy with a suggestion,
   then try to insert a space, if applicable.

   用 `suggestion` 替换代理中的当前单词，然后尝试插入空格（如果适用）。

   If a space is automatically inserted, the proxy will be
   set to an `autoInserted` state.

   如果空格被自动插入，代理将被设置为 `autoInserted` 状态。
   */
  func insertAutocompleteSuggestion(_ suggestion: AutocompleteSuggestion, tryInsertSpace: Bool = true) {
    replaceCurrentWord(with: suggestion.text)
    guard tryInsertSpace else { return }
    tryInsertSpaceAfterAutocomplete()
  }

  /**
   Try inserting a space into the proxy after inserting an
   autocomplete suggestion.

   尝试在插入自动完成的 `suggestion` 后在代理中插入一个空格。

   Calling this function instead of just inserting a space
   puts the proxy in the correct autocomplete state.

   调用该函数而不是直接插入空格，会使代理处于正确的自动完成状态。
   */
  func tryInsertSpaceAfterAutocomplete() {
    let space = " "
    let hasPreviousSpace = documentContextBeforeInput?.hasSuffix(space) ?? false
    let hasNextSpace = documentContextAfterInput?.hasPrefix(space) ?? false
    if hasPreviousSpace || hasNextSpace { return }
    insertText(space)
    setState(.autoInserted)
  }

  /**
   Try re-inserting any space that were previously removed
   by `tryRemoveAutocompleteInsertedSpace`.

   尝试重新插入之前被 `tryRemoveAutocompleteInsertedSpace` 移除的空格。
   */
  func tryReinsertAutocompleteRemovedSpace() {
    if hasAutocompleteRemovedSpace { insertText(" ") }
    resetState()
  }

  /**
   Try removing any space before the current text input if
   is was inserted by `insertAutocompleteSuggestion`.

   如果当前文本输入是由 `insertAutocompleteSuggestion` 插入的，
   则尝试删除该文本输入前的空格。

   If a space is automatically removed, this proxy will be
   set to an `autoRemoved` state.

   如果空格被自动移除，该代理将被设置为 `autoRemoved` 状态。
   */
  func tryRemoveAutocompleteInsertedSpace() {
    guard hasAutocompleteInsertedSpace else { return resetState() }
    deleteBackward()
    setState(.autoRemoved)
  }
}

private extension UITextDocumentProxy {
  func resetState() {
    setState(.none)
  }

  func setState(_ state: AutocompleteSpaceState) {
    ProxyState.state = state
  }
}

/**
 This class is a private way to store state for a text proxy.

 该类是存储文本代理状态的一种私有方式。
 */
private final class ProxyState {
  private init() {}

  /**
   This flag is used to keep track of if a space character
   has been inserted by `insertAutocompleteSuggestion`.
   */
  static var state = AutocompleteSpaceState.none
}
