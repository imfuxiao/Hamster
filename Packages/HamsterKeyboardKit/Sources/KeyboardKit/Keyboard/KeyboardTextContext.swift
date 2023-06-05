//
//  KeyboardTextContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-01-22.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import Combine
import Foundation

/**
 This class provides keyboard extensions with contextual and
 observable information about the text in the document proxy.

 该类为键盘扩展提供有关文档代理中文本的上下文和可观察信息。

 KeyboardKit automatically creates an instance of this class
 and binds the created instance to the keyboard controller's
 ``KeyboardInputViewController/keyboardTextContext``.

 KeyboardKit 会自动创建该类的实例，并将创建的实例绑定到
 键盘 controller 的 ``KeyboardInputViewController/keyboardTextContext`` 中。

 You can get this information directly from the proxy, using
 either the controller or the ``KeyboardContext`` to get the
 proxy instance, but the controller will continously sync it
 from the proxy to the context to let you observe it as well.

 您可以使用 controller 或 ``KeyboardContext`` 直接从代理获取这些信息，
 但 contorller 会不断将这些信息从代理同步到上下文中，以便您也能观察到这些信息。
 */
public class KeyboardTextContext: ObservableObject {
  /**
   The document context (content) before the input cursor.

   输入光标前的文档上下文（内容）。

   Note that for longer texts, this will most often not be
   the full content, since keyboard extensions get limited
   text back from the proxy.

   请注意，对于较长的文本，这通常不是完整的内容，因为键盘扩展从代理获取的文本有限。
   */
  @Published
  public var documentContextBeforeInput: String?

  /**
   The document context (content) after the input cursor.

   输入光标后的文档上下文（内容）。

   Note that for longer texts, this will most often not be
   the full content, since keyboard extensions get limited
   text back from the proxy.

   请注意，对于较长的文本，这通常不是完整的内容，因为键盘扩展从代理获取的文本有限。
   */
  @Published
  public var documentContextAfterInput: String?

  /**
   The currently selected text, if any.

   当前选中的文本（如果有）。

   Note that for longer texts, this will most often not be
   the full content, since keyboard extensions get limited
   text back from the proxy.

   请注意，对于较长的文本，这通常不是完整的内容，因为键盘扩展从代理获取的文本有限。
   */
  @Published
  public var selectedText: String?

  /**
   Create a context instance.
   */
  public init() {}
}

public extension KeyboardTextContext {
  /**
   Get the before and after document context combined.

   合并光标前后的文档上下文（内容）。

   Note that for longer texts, this will most often not be
   the full content, since keyboard extensions get limited
   text back from the proxy.

   请注意，对于较长的文本，这通常不是完整的内容，因为键盘扩展从代理获取的文本有限。
   */
  var documentContext: String? {
    let before = documentContextBeforeInput ?? ""
    let after = documentContextAfterInput ?? ""
    return before + after
  }
}

public extension KeyboardTextContext {
  /**
   Sync the context with the current state of the keyboard
   input view controller.

   将上下文与 KeyboardInputViewController 的当前状态同步。
   */
  func sync(with controller: KeyboardInputViewController) {
    DispatchQueue.main.async {
      self.syncAfterAsync(with: controller)
    }
  }
}

extension KeyboardTextContext {
  /**
   Perform this after an async delay, to make sure that we
   have the latest information.

   在异步延迟后执行此操作，以确保我们获得最新信息。
   */
  func syncAfterAsync(with controller: KeyboardInputViewController) {
    let proxy = controller.textDocumentProxy
    if documentContextBeforeInput != proxy.documentContextBeforeInput {
      documentContextBeforeInput = proxy.documentContextBeforeInput
    }
    if documentContextAfterInput != proxy.documentContextAfterInput {
      documentContextAfterInput = proxy.documentContextAfterInput
    }
    if selectedText != proxy.selectedText {
      selectedText = proxy.selectedText
    }
  }
}
