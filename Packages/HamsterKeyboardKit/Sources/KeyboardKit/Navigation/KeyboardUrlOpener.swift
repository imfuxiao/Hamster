//
//  KeyboardUrlOpener.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-05-29.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This class can be used to open URLs from a keyboard without
 having to use `UIApplication`.

 该类可用于通过键盘打开 URL，而无需使用 `UIApplication`。

 You can use ``KeyboardUrlOpener/shared`` to avoid having to
 create custom instances. Note that you have to manually set
 the ``controller`` when you create a custom opener or use a
 custom controller.

 您可以使用 ``KeyboardUrlOpener/shared`` 来避免创建自定义实例。
 请注意，在创建自定义 opener 或使用自定义 controller 时，必须手动设置属性 ``controller`` 。
 */
public class KeyboardUrlOpener {
  public init() {}

  public enum UrlError: Error {
    case nilUrl, noKeyboardController
  }

  /// A shared url opener.
  public static let shared = KeyboardUrlOpener()

  /// The controller to use to open the URL.
  public unowned var controller: KeyboardController?

  /// Open a custom URL.
  public func open(_ url: URL?) throws {
    guard let controller else { throw UrlError.noKeyboardController }
    controller.openUrl(url)
  }
}
