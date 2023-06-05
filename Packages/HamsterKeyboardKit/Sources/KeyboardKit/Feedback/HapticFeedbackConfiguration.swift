//
//  HapticFeedbackConfiguration.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-10-15.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This struct specifies haptic feedback for a custom keyboard.
 
 此结构用于指定自定义键盘的触觉反馈。
 */
public struct HapticFeedbackConfiguration: Codable, Equatable {
  /**
   This struct is used for action-specific haptic feedback.
   
   该结构用于特定操作的触觉反馈。
   */
  public struct ActionFeedback: Codable, Equatable {
    public init(
      action: KeyboardAction,
      gesture: KeyboardGesture,
      feedback: HapticFeedback
    ) {
      self.action = action
      self.gesture = gesture
      self.feedback = feedback
    }
        
    public let action: KeyboardAction
    public let gesture: KeyboardGesture
    public let feedback: HapticFeedback
  }
 
  /**
   The feedback to use for taps.
   
   用于点击的反馈。
   */
  public var tap: HapticFeedback
    
  /**
   The feedback to use for double taps.
   
   用于双击的反馈。
   */
  public var doubleTap: HapticFeedback
    
  /**
   The feedback to use for long presses.
   
   用于长按的反馈。
   */
  public var longPress: HapticFeedback
    
  /**
   The feedback to use for long presses on space.
   
   用于长按空格的反馈。
   */
  public var longPressOnSpace: HapticFeedback
    
  /**
   The feedback to use for repeat.
   
   用于重复的反馈。
   */
  public var `repeat`: HapticFeedback
    
  /**
   A list of action/gesture-specific feedback.
   
   针对操作/手势的反馈列表。
   */
  public var actions: [ActionFeedback]
  
  /**
   Create a feedback configuration.
     
   - Parameters:
     - tap: The feedback to use for taps, by default `.none`.
     - doubleTap: The feedback to use for double taps, by default `.none`.
     - longPress: The feedback to use for long presses, by default `.none`.
     - longPressOnSpace: The feedback to use for long presses on space, by default `.mediumImpact`.
     - repeat: The feedback to use for repeat, by default `.none`.
     - actions: A list of action/gesture-specific feedback, by default `empty`.
   */
  public init(
    tap: HapticFeedback = .none,
    doubleTap: HapticFeedback = .none,
    longPress: HapticFeedback = .none,
    longPressOnSpace: HapticFeedback = .mediumImpact,
    repeat: HapticFeedback = .none,
    actions: [ActionFeedback] = []
  ) {
    self.tap = tap
    self.doubleTap = doubleTap
    self.longPress = longPress
    self.longPressOnSpace = longPressOnSpace
    self.repeat = `repeat`
    self.actions = actions
  }
}

public extension HapticFeedbackConfiguration {
  /**
    This specifies an enabled haptic feedback configuration,
    where all feedback types generate some kind of feedback.
   
    这指定了一个 "enable" 的触觉反馈配置，其中所有反馈类型都会产生某种反馈。
   */
  static let enabled = HapticFeedbackConfiguration(
    tap: .lightImpact,
    doubleTap: .lightImpact,
    longPress: .mediumImpact,
    longPressOnSpace: .mediumImpact,
    repeat: .selectionChanged
  )
    
  /**
   This configuration disables all haptic feedback.
   
   此配置禁用所有触觉反馈。
   */
  static let noFeedback = HapticFeedbackConfiguration(
    tap: .none,
    doubleTap: .none,
    longPress: .none,
    longPressOnSpace: .none,
    repeat: .none
  )
    
  /**
    This specifies a standard haptic feedback configuration,
    where only `longPressOnSpace` triggers feedback.
   
   这指定了标准触觉反馈配置，其中只有 "longPressOnSpace" 会触发反馈。
   */
  static let standard = HapticFeedbackConfiguration()
}
