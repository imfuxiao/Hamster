//
//  KeyboardAction+KeyboardActions.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-07-04.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This typealias represents a ``KeyboardAction`` array.

 此类型别名代表一个 ``KeyboardAction`` 数组。

 The typealias makes it easier to create and handle keyboard
 action rows and collections.

 通过类型别名，可以更轻松地创建和处理键盘操作的行和集合。
 */
public typealias KeyboardActions = [KeyboardAction]

public extension KeyboardActions {
  /**
    Create keyboard actions by mapping strings to a list of
    ``KeyboardAction/character(_:)`` actions.

   通过将字符串映射到 ``KeyboardAction/character(_:)`` 列表来创建键盘操作。
   */
  init(characters: [String]) {
    self = characters.map { .character($0) }
  }

  init(symbols: [String]) {
    self = symbols.map { KeyboardAction.symbol(Symbol(char: $0)) }
  }

  /**
   Create keyboard actions by mapping image names to a set
   of ``KeyboardAction/image(description:keyboardImageName:imageName:)``
   actions, using certain name prefix and suffix rules.

   使用特定的名称前缀和后缀规则，将图像名称映射到一组
   ``KeyboardAction/image(description:keyboardImageName:imageName:)``，
   从而创建键盘操作。

   The optional keyboard image and localization key prefix
   and suffix parameters can be used to generate different
   names for each image name in the image names array. For
   instance, using `emoji-` as a `keyboardImageNamePrefix`
   will generate an image action where `keyboardName` will
   prefixed with `emoji-`.

   可选的键盘图像和本地化按键前缀和后缀参数可用于为图像名称数组中的每个图像生成不同的名称。
   例如，使用 `emojii-` 作为 `keyboardImageNamePrefix` 将生成一个图像操作，
   其中 `keyboardName` 将以 `emojii-` 作为前缀。

   The localization keys parameters are optional, but will
   be used to improve the overall image accessibility.

   本地化键参数是可选的，将用于提高整体图像的可访问性。

   `throwAssertionFailure` will cause your app to crash in
   debug if a translation can't be retrieved for a certain
   image. This helps you assert that all image actions are
   accessible. It's `true` by default.

   `throwAssertionFailure` 会导致应用程序在无法获取特定图像的时在调试中崩溃。
   这可以帮助您断言所有图像操作都是可访问的。默认为 `true`。
   */
  init(
    imageNames: [String],
    keyboardImageNamePrefix keyboardPrefix: String = "",
    keyboardImageNameSuffix keyboardSuffix: String = "",
    localizationKeyPrefix keyPrefix: String = "",
    localizationKeySuffix keySuffix: String = "",
    throwAssertionFailure throwFailure: Bool = true)
  {
    self = imageNames.map {
      .image(
        description: $0.translatedDescription(keyPrefix, keySuffix, throwFailure),
        keyboardImageName: "\(keyboardPrefix)\($0)\(keyboardSuffix)",
        imageName: $0)
    }
  }
}

public extension KeyboardActions {
  /**
   Get the leading character margin action.

   获取 leading 字符边距的操作。
   */
  var leadingCharacterMarginAction: KeyboardAction {
    characterMarginAction(for: first { $0.isInputAction })
  }

  /**
   Get the trailing character margin action.

   获取 trailing 字符边距操作。
   */
  var trailingCharacterMarginAction: KeyboardAction {
    characterMarginAction(for: last { $0.isInputAction })
  }

  /**
   Get a margin action for a certain action, if any.

   获取某个操作的对应的边距操作（如果有）。

   This function returns `characterMargin` for `character`
   and `none` for all other action types.

   此函数对 `character` 返回 `characterMargin`，对所有其他操作类型返回 `none`。
   */
  func characterMarginAction(for action: KeyboardAction?) -> KeyboardAction {
    guard let action = action else { return .none }
    switch action {
    case .character(let char): return .characterMargin(char)
    default: return .none
    }
  }
}

private extension String {
  /// 翻译说明
  func translatedDescription(
    _ prefix: String,
    _ suffix: String,
    _ throwAssertionFailure: Bool) -> String
  {
    let key = "\(prefix)\(self)\(suffix)"
    let description = NSLocalizedString(key, comment: "")
    if key == description && throwAssertionFailure {
      assertionFailure("Translation is missing for \(self)")
    }
    return description
  }
}
