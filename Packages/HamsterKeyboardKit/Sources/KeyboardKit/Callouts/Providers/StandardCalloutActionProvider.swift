//
//  StandardCalloutActionProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This provider is initialized with a collection of localized
 providers, and will use the one with the same locale as the
 provided ``KeyboardContext``.

 该 provider 通过本地化 provider 集合进行初始化，
 并将使用与所提供的 ``KeyboardContext`` 具有相同本地化设置的提供程序。
 */
open class StandardCalloutActionProvider: CalloutActionProvider {
  /**
   The keyboard context to use.

   要使用的键盘上下文。
   */
  public let keyboardContext: KeyboardContext

  private let provider: CalloutActionProvider

  /**
   Create a standard callout action provider.

    - Parameters:
      - keyboardContext: The keyboard context to use.
      - provider: The action providers to use.
   */
  public init(
    keyboardContext: KeyboardContext,
    provider: CalloutActionProvider = standardProvider
  ) {
    self.keyboardContext = keyboardContext
    self.provider = provider
  }

  /**
   Get callout actions for the provided `action`.

   为提供的 `action`获取呼出操作。
   */
  open func calloutActions(for action: KeyboardAction) -> [KeyboardAction] {
    provider(for: keyboardContext).calloutActions(for: action)
  }

  /**
   Get the provider to use for the provided `context`.

   获取要用于所提供的`context`的 provider。
   */
  open func provider(for context: KeyboardContext) -> CalloutActionProvider {
    provider
  }
}

public extension StandardCalloutActionProvider {
  /**
   Get the standard callout action provider.

   获取标准呼出操作 provider。

   This can be set to change the standard value everywhere.

   可以在任何地方将其设置为标准的 provider。
   */
  static var standardProvider: CalloutActionProvider {
    guard let provider = try? EnglishCalloutActionProvider() else { fatalError("EnglishCalloutActionProvider could not be created.") }
    return provider
  }
}
