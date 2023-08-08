//
//  AutocompleteSuggestion.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-09-12.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This struct is a standard suggestion that can be used by an
 autocomplete suggestion provider.
 
 该结构是一个标准自动完成建议，可供 autocomplete suggestion provider 使用。
 */
public struct AutocompleteSuggestion {
  /**
   The text that should be sent to the text document proxy.
   
   应发送到 text document proxy 的文本。
   */
  public var text: String
    
  /**
   The text that should be presented to the user.
   
   应呈现给用户的文本。
   */
  public var title: String
    
  /**
   Whether or not this is an autocompleting suggestion.
   
   这是否是一项自动完成建议。

   These suggestions are typically shown in white, rounded
   squares when presented in an iOS system keyboard.
   
   在 iOS 系统键盘中，这些建议通常以白色圆角方形显示。
   */
  public var isAutocomplete: Bool
    
  /**
   Whether or not this is an unknown suggestion.
   
   这是否是一个未知的建议。

   These suggestions are typically surrounded by quotation
   marks when presented in an iOS system keyboard.
   
   这些建议在 iOS 系统键盘中显示时，通常会用引号包围。
   */
  public var isUnknown: Bool
    
  /**
   An optional subtitle that can complete the `title`.
   
   一个可选的副标题，它可以使 "title" 更完整。
   */
  public var subtitle: String?
    
  /**
   An optional dictionary that can contain additional info.
   
   可选字典，可包含其他信息。
   */
  public var additionalInfo: [String: Any]
  
  /**
   Create a suggestion with completely custom properties.

   - Parameters:
     - text: The text that should be sent to the text document proxy.
     - title: The text that should be presented to the user, by default `text`.
     - isAutocomplete: Whether or not this is an autocompleting suggestion, by default `false`.
     - isUnknown: Whether or not this is an unknown suggestion, by default `false`.
     - subtitle: An optional subtitle that can complete the `title`, by default `nil`.
     - additionalInfo: An optional dictionary that can contain additional info, by default `empty`.
   */
  public init(
    text: String,
    title: String? = nil,
    isAutocomplete: Bool = false,
    isUnknown: Bool = false,
    subtitle: String? = nil,
    additionalInfo: [String: Any] = [:]
  ) {
    self.text = text
    self.title = title ?? text
    self.isAutocomplete = isAutocomplete
    self.isUnknown = isUnknown
    self.subtitle = subtitle
    self.additionalInfo = additionalInfo
  }
}
