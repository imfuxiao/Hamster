//
//  AppSettings+Yaml.swift
//  Hamster
//
//  Created by morse on 6/5/2023.
//

import Foundation
import Yams

public extension HamsterAppSettings {
  /// 将App设置值转为yaml
  func yaml() -> String {
    var map: [String: Any] = [:]

    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      guard let label = child.label else { continue }

      let key = String(describing: label)
      let yamlKey = (key.hasPrefix("_") ? String(key.dropFirst()) : key).underscoresToWords()

      switch child.value {
      case var value as Published<Bool>:
        value.projectedValue.sink { map[yamlKey] = $0 }.store(in: &cancelable)
      case var value as Published<String>:
        value.projectedValue.sink { map[yamlKey] = $0 }.store(in: &cancelable)
      case var value as Published<Int>:
        value.projectedValue.sink { map[yamlKey] = $0 }.store(in: &cancelable)
      case var value as Published<Int32>:
        value.projectedValue.sink { map[yamlKey] = $0 }.store(in: &cancelable)
      // 以下属性在其他地方存储
//      case var value as Published<[ColorSchema]>:
//      case var value as Published<[Schema]>:
//      case var value as Published<[String: String]>:
      default:
        Logger.shared.log.debug("label name = \(key.underscoresToWords()), label value not match type = \(child.value)")
      }
    }
    var yaml = ""
    do {
      yaml = try Yams.dump(object: ["app_settings": map])
    } catch {
      Logger.shared.log.error(error.localizedDescription)
    }
    return yaml
  }

  /// 根据yaml内容，重置AppSettings中的值
  func reset(node: Yams.Node) {
    guard let settings = node["app_settings"] else { return }
    guard let keys = settings.mapping?.keys else { return }
    for key in keys {
      if let field = key.string, let value = settings[key] {
        Logger.shared.log.debug("field: \(field) value: \(value)")
        self.setValue(field, node: value)
      }
    }
  }

  func setValue(_ name: String, node: Yams.Node) {
    switch name {
    case "enable_input_embedded_mode":
      if let value = node.bool {
        self.enableInputEmbeddedMode = value
        Logger.shared.log.debug("set enableInputEmbeddedMode = \(value)")
      }
    case "enable_keyboard_automatically_lowercase":
      if let value = node.bool {
        self.enableKeyboardAutomaticallyLowercase = value
        Logger.shared.log.debug("set enableKeyboardAutomaticallyLowercase = \(value)")
      }
    case "enable_keyboard_feedback_haptic":
      if let value = node.bool {
        self.enableKeyboardFeedbackHaptic = value
        Logger.shared.log.debug("set enableKeyboardFeedbackHaptic = \(value)")
      }
    case "enable_keyboard_feedback_sound":
      if let value = node.bool {
        self.enableKeyboardFeedbackSound = value
        Logger.shared.log.debug("set enableKeyboardFeedbackSound = \(value)")
      }
    case "enable_keyboard_swipe_gesture_symbol":
      if let value = node.bool {
        self.enableKeyboardSwipeGestureSymbol = value
        Logger.shared.log.debug("set enableKeyboardSwipeGestureSymbol = \(value)")
      }
    case "enable_number_nine_grid":
      if let value = node.bool {
        self.enableNumberNineGrid = value
        Logger.shared.log.debug("set enableNumberNineGrid = \(value)")
      }
    case "enable_rime_color_schema":
      if let value = node.bool {
        self.enableRimeColorSchema = value
        Logger.shared.log.debug("set enableRimeColorSchema = \(value)")
      }
    case "enable_space_sliding":
      if let value = node.bool {
        self.enableSpaceSliding = value
        Logger.shared.log.debug("set enableRimeColorSchema = \(value)")
      }
    case "enableAppleCloud":
      if let value = node.bool {
        self.enableAppleCloud = value
        Logger.shared.log.debug("set enableAppleCloud = \(value)")
      }
    case "is_first_launch":
      if let value = node.bool {
        self.isFirstLaunch = value
        Logger.shared.log.debug("set isFirstLaunch = \(value)")
      }
    case "keyboard_feedback_haptic_intensity":
      if let value = node.int {
        self.keyboardFeedbackHapticIntensity = value
        Logger.shared.log.debug("set keyboardFeedbackHapticIntensity = \(value)")
      }
    case "last_use_rime_input_schema":
      if let value = node.string {
        self.lastUseRimeInputSchema = value
        Logger.shared.log.debug("set lastUseRimeInputSchema = \(value)")
      }
    case "rime_candidate_comment_font_size":
      if let value = node.int {
        self.rimeCandidateCommentFontSize = value
        Logger.shared.log.debug("set rimeCandidateCommentFontSize = \(value)")
      }
    case "rime_candidate_title_font_size":
      if let value = node.int {
        self.rimeCandidateTitleFontSize = value
        Logger.shared.log.debug("set rimeCandidateTitleFontSize = \(value)")
      }
    case "rime_color_schema":
      if let value = node.string {
        self.rimeColorSchema = value
        Logger.shared.log.debug("set rimeColorSchema = \(value)")
      }
    case "rime_input_schema":
      if let value = node.string {
        self.rimeInputSchema = value
        Logger.shared.log.debug("set rimeInputSchema = \(value)")
      }
    case "rime_max_candidate_size":
      if let value = node.int {
        self.rimeMaxCandidateSize = Int32(value)
        Logger.shared.log.debug("set rimeMaxCandidateSize = \(value)")
      }
    case "rime_need_override_user_data_directory":
      if let value = node.bool {
        self.rimeNeedOverrideUserDataDirectory = value
        Logger.shared.log.debug("set rimeNeedOverrideUserDataDirectory = \(value)")
      }
    case "rime_use_squirrel_settings":
      if let value = node.bool {
        self.rimeUseSquirrelSettings = value
        Logger.shared.log.debug("set rimeUseSquirrelSettings = \(value)")
      }
    case "show_key_extension_area":
      if let value = node.bool {
        self.showKeyExtensionArea = value
        Logger.shared.log.debug("set showKeyExtensionArea = \(value)")
      }
    case "show_key_press_bubble":
      if let value = node.bool {
        self.showKeyPressBubble = value
        Logger.shared.log.debug("set showKeyPressBubble = \(value)")
      }
    case "show_keyboard_dismiss_button":
      if let value = node.bool {
        self.showKeyboardDismissButton = value
        Logger.shared.log.debug("set showKeyboardDismissButton = \(value)")
      }
    case "show_space_left_button":
      if let value = node.bool {
        self.showSpaceLeftButton = value
        Logger.shared.log.debug("set showSpaceLeftButton = \(value)")
      }
    case "show_space_right_button":
      if let value = node.bool {
        self.showSpaceRightButton = value
        Logger.shared.log.debug("set showSpaceRightButton = \(value)")
      }
    case "show_space_right_switch_language_button":
      if let value = node.bool {
        self.showSpaceRightSwitchLanguageButton = value
        Logger.shared.log.debug("set showSpaceRightSwitchLanguageButton = \(value)")
      }
    case "space_left_button_value":
      if let value = node.string {
        self.spaceLeftButtonValue = value
        Logger.shared.log.debug("set spaceLeftButtonValue = \(value)")
      }
    case "space_right_button_value":
      if let value = node.string {
        self.spaceRightButtonValue = value
        Logger.shared.log.debug("set spaceRightButtonValue = \(value)")
      }
    case "switch_language_button_in_space_left":
      if let value = node.bool {
        self.switchLanguageButtonInSpaceLeft = value
        Logger.shared.log.debug("set switchLanguageButtonInSpaceLeft = \(value)")
      }
    case "switch_traditional_chinese":
      if let value = node.bool {
        self.switchTraditionalChinese = value
        Logger.shared.log.debug("set switch_traditional_chinese = \(value)")
      }
    case "x_swipe_sensitivity":
      if let value = node.int {
        self.xSwipeSensitivity = value
        Logger.shared.log.debug("set xSwipeSensitivity = \(value)")
      }
    case "copy_to_cloud_filter_regex":
      if let value = node.string {
        self.copyToCloudFilterRegex = value
        Logger.shared.log.debug("set copyToCloudFilterRegex = \(value)")
      }
    case "candidate_bar_height":
      if let value = node.int {
        self.candidateBarHeight = CGFloat(value)
        Logger.shared.log.debug("set candidateBarHeight = \(value)")
      }
    case "enable_candidate_bar":
      if let value = node.bool {
        self.enableCandidateBar = value
        Logger.shared.log.debug("set enableCandidateBar = \(value)")
      }
    case "enable_show_candidate_index":
      if let value = node.bool {
        self.enableShowCandidateIndex = value
        Logger.shared.log.debug("set enableShowCandidateIndex = \(value)")
      }
    default:
      break
    }
  }
}

extension String {
  func underscoresToWords() -> String {
    return unicodeScalars.dropFirst().reduce(String(prefix(1))) {
      CharacterSet.uppercaseLetters.contains($1)
        ? $0 + "_" + String($1).lowercased()
        : $0 + String($1)
    }
  }

  func underscoresConverCamelCase() -> String {
    return unicodeScalars.dropFirst().reduce(String(prefix(1))) {
      $1 == "_" ? $0 + String($1).uppercased() : $0 + String($1)
    }
  }
}
