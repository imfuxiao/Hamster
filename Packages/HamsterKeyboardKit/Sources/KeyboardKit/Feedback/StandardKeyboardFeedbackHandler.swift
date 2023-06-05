//
//  StandardKeyboardFeedbackHandler.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This feedback handler is used by default by KeyboardKit and
 can trigger audio and haptic feeeback.
 
 KeyboardKit 默认使用该反馈处理程序，它可以触发音频和触觉反馈。
 
 You can inherit this class and override any open properties
 and functions to customize the standard behavior.
 
 您可以继承该类，并覆盖任何 open 的属性和函数，以自定义标准行为。
 
 The provided `settings` instance is used to determine which
 kind of feedback that will be triggered. This means you can
 change feedback behavior at any time.
 
 所提供的 `settings` 实例用于确定将触发哪种反馈。这意味着您可以随时更改反馈行为。
 */
open class StandardKeyboardFeedbackHandler: KeyboardFeedbackHandler {
  // MARK: - Properties

  /**
   The feedback settings to use.
   
   使用的反馈设置。
   
   `settings` 实例用于确定将触发哪种反馈。这意味着您可以随时更改反馈行为。
   */
  public let settings: KeyboardFeedbackSettings
    
  /**
   The audio configuration to use, derived from ``settings``.
   
   使用的音频反馈配置，源自 ``settings``。
   */
  public var audioConfig: AudioFeedbackConfiguration {
    settings.audioConfiguration
  }
    
  /**
   The haptic configuration to use, derived from ``settings``.
   
   使用的触觉反馈配置，源自 ``settings``。
   */
  public var hapticConfig: HapticFeedbackConfiguration {
    settings.hapticConfiguration
  }
  
  // MARK: - Initializations
  
  /**
   Create a standard keyboard feedback handler instance.
   
   创建标准键盘反馈处理程序实例
     
   - Parameters:
     - settings: The feedback settings to use. 要使用的反馈设置。
   */
  public init(settings: KeyboardFeedbackSettings) {
    self.settings = settings
  }
  
  // MARK: - Functions
    
  /**
   Trigger feedback for when a `gesture` is performed on a
   certain `action`.
   
   当对某个 `action` 执行特定 `gesture` 时触发反馈。
     
   You can override this function to customize the default
   feedback behavior.
   
   您可以覆盖此函数，自定义默认反馈行为。
   */
  open func triggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    triggerAudioFeedback(for: gesture, on: action)
    triggerHapticFeedback(for: gesture, on: action)
  }
    
  /**
   Trigger audio feedback for when a `gesture` is performed on a
   certain `action`.
   
   当对某个 `action` 执行特定 `gesture` 时触发音频反馈。
     
   You can override this function to customize the default
   audio feedback behavior.
   
   您可以覆盖此功能，自定义默认的音频反馈行为。
   */
  open func triggerAudioFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    let custom = audioConfig.actions.first { $0.action == action }
    if let custom = custom { return custom.feedback.trigger() }
    if action == .space && gesture == .longPress { return }
    if action == .backspace { return audioConfig.delete.trigger() }
    if action.isInputAction { return audioConfig.input.trigger() }
    if action.isSystemAction { return audioConfig.system.trigger() }
  }
    
  /**
   Trigger haptic feedback for when a `gesture` is performed on a
   certain `action`.
   
   当对某个 `action` 执行特定 `gesture` 时触发触觉反馈。
     
   You can override this function to customize the default
   haptic feedback behavior.
   
   您可以覆盖此功能，自定义默认触觉反馈行为。
   */
  open func triggerHapticFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    guard action != .none else { return }
    let custom = hapticConfig.actions.first { $0.action == action && $0.gesture == gesture }
    if let custom = custom { return custom.feedback.trigger() }
    if action == .space && gesture == .longPress { return hapticConfig.longPressOnSpace.trigger() }
    switch gesture {
    case .doubleTap: hapticConfig.doubleTap.trigger()
    case .longPress: hapticConfig.longPress.trigger()
    case .press: hapticConfig.tap.trigger()
    case .release: hapticConfig.tap.trigger()
    case .repeatPress: hapticConfig.repeat.trigger()
    default:
      hapticConfig.tap.trigger()
    }
  }
}
