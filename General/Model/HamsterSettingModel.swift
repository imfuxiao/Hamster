//
//  HamsterYaml.swift
//  Hamster
//
//  Created by morse on 2023/6/19.
//

import Foundation

struct HamsterSettingModel: Codable {
  var appSettings: AppSettingsModel
  var keyboardSettings: KeyboardSettingsModel

  enum CodingKeys: String, CodingKey {
    case appSettings = "app_settings"
    case keyboardSettings = "keyboard_settings"
  }
}

struct AppSettingsModel: Codable {
  var isFirstLaunch: Bool?
  var showKeyPressBubble: Bool

  enum CodingKeys: String, CodingKey {
    case showKeyPressBubble = "show_key_bubble_on_press"
  }
}

struct KeyboardSettingsModel: Codable {
  var enableSymbolKeyboard: Bool
  var keys: [String]

  enum CodingKeys: String, CodingKey {
    case enableSymbolKeyboard = "enable_symbol_keyboard"
    case keys
  }
}
