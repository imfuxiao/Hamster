//
//  Proxy+Preview.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-25.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

public extension UITextDocumentProxy where Self == PreviewTextDocumentProxy {
  /**
   This preview proxy can be used in SwiftUI previews.

   该预览代理可用于 SwiftUI 预览。
   */
  static var preview: UITextDocumentProxy { PreviewTextDocumentProxy() }
}

/**
 This document proxy can be used in SwiftUI previews.

 此文档代理可用于 SwiftUI 预览。
 */
public class PreviewTextDocumentProxy: NSObject, UITextDocumentProxy {
  override public init() {
    super.init()
  }

  // 自动大写类型
  public var autocapitalizationType: UITextAutocapitalizationType = .none
  public var documentContextBeforeInput: String?
  public var documentContextAfterInput: String?
  public var hasText: Bool = false
  public var selectedText: String?
  public var documentInputMode: UITextInputMode?
  public var documentIdentifier: UUID = .init()
  public var returnKeyType: UIReturnKeyType = .default

  public func adjustTextPosition(byCharacterOffset offset: Int) {}
  public func deleteBackward() {}
  public func insertText(_ text: String) {}
  public func setMarkedText(_ markedText: String, selectedRange: NSRange) {}
  public func unmarkText() {}
}
