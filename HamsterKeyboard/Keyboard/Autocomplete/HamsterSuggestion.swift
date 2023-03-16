//
//  HamsterSuggestion.swift
//  HamsterKeyboard
//
//  Created by morse on 15/3/2023.
//

import Foundation

public struct HamsterSuggestion: Identifiable {
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
  
  public var id = UUID()
  
  /**
   The text that should be sent to the text document proxy.
   */
  public var text: String
  
  /**
   The text that should be presented to the user.
   */
  public var title: String
  
  /**
   Whether or not this is an autocompleting suggestion.
   
   These suggestions are typically shown in white, rounded
   squares when presented in an iOS system keyboard.
   */
  public var isAutocomplete: Bool
  
  /**
   Whether or not this is an unknown suggestion.
   
   These suggestions are typically surrounded by quotation
   marks when presented in an iOS system keyboard.
   */
  public var isUnknown: Bool
  
  /**
   An optional subtitle that can complete the `title`.
   */
  public var subtitle: String?
  
  /**
   An optional dictionary that can contain additional info.
   */
  public var additionalInfo: [String: Any]
}

extension HamsterSuggestion {
  var comment: String? {
    get {
      if let comment = additionalInfo["comment"] {
        return comment as? String
      }
      return nil
    }
    set {
      additionalInfo["comment"] = newValue
    }
  }
}
