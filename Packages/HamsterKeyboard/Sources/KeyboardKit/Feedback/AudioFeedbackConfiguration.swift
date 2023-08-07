//
//  AudioFeedbackConfiguration.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-10-15.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This struct specifies audio feedback for a custom keyboard.
 
 此结构用于指定自定义键盘的音频反馈。
 */
public struct AudioFeedbackConfiguration: Codable, Equatable {
  /**
   This struct is used for action-specific audio feedback.
   
   该结构用于特定操作的音频反馈。
   */
  public struct ActionFeedback: Codable, Equatable {
    public let action: KeyboardAction
    public let feedback: AudioFeedback
    
    public init(
      action: KeyboardAction,
      feedback: AudioFeedback
    ) {
      self.action = action
      self.feedback = feedback
    }
  }
    
  /**
   The audio to trigger when a delete key is pressed.
   
   按下删除键时触发的音频。
   */
  public var delete: AudioFeedback
 
  /**
   The audio to trigger when an input key is pressed.
   
   按下输入按键时触发的音频。
   */
  public var input: AudioFeedback
    
  /**
   The audio to trigger when a system key is pressed.
   
   按下系统按键时触发的音频。
   */
  public var system: AudioFeedback
    
  /**
   The audio to trigger when an action is triggered.
   
   触发操作时要触发的音频。
   */
  public var actions: [ActionFeedback]
  
  /**
   Create a feedback configuration.
     
   - Parameters:
     - input: The feedback to use for input keys, by default `.input`.
     - delete: The feedback to use for delete keys, by default `.delete`.
     - system: The feedback to use for system keys, by default `.system`.
     - actions: A list of action-specific feedback, by default `empty`.
   */
  public init(
    input: AudioFeedback = .input,
    delete: AudioFeedback = .delete,
    system: AudioFeedback = .system,
    actions: [ActionFeedback] = []
  ) {
    self.input = input
    self.delete = delete
    self.system = system
    self.actions = actions
  }
}

public extension AudioFeedbackConfiguration {
  /**
    This specifies an `enabled` audio feedback config where
    all feedback types generate some kind of feedback.
   
   这指定了一个 "enabled" 的音频反馈配置，其中所有反馈类型都会产生某种反馈。
   */
  static let enabled: AudioFeedbackConfiguration = .standard
    
  /**
   This configuration disables all audio feedback.
   
   此配置禁用所有音频反馈。
   */
  static let noFeedback = AudioFeedbackConfiguration(
    input: .none,
    delete: .none,
    system: .none
  )
    
  /**
    This configuration uses standard audio feedbacks, which
    tries to replicate the standard system behavior.
   
    该配置使用标准音频反馈，试图复制标准系统键盘音频反馈行为。
   */
  static let standard = AudioFeedbackConfiguration()
}
