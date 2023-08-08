//
//  RepeatGestureTimer.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-28.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This class is used to handle repeating actions on a
 keyboard button.

 该类用于处理键盘按钮上的重复操作。
 */
public class RepeatGestureTimer {
  public init() {}

  deinit { stop() }

  private var timer: Timer?

  private var startDate: Date?

  /**
   The timer tick interval.

   计时器的频率。默认为0.1秒
   */
  public var timeInterval: TimeInterval = 0.1
}

public extension RepeatGestureTimer {
  /**
   This shared timer can be used if you only need to track
   a single thing.

   如果您只需要跟踪一件事，就可以使用这种共享计时器。
   */
  static let shared = RepeatGestureTimer()
}

public extension RepeatGestureTimer {
  /**
   The time for how long the timer has been active.

   计时器已激活时长。
   */
  var duration: TimeInterval? {
    guard let date = startDate else { return nil }
    return Date().timeIntervalSince(date)
  }

  /**
   Whether or not the timer is active.

   计时器是否处于活动状态。
   */
  var isActive: Bool { timer != nil }

  /**
   Start the timer.

   启动计时器。
   */
  func start(action: @escaping () -> Void) {
    if isActive { return }
    stop()
    startDate = Date()
    let timer = Timer.scheduledTimer(
      withTimeInterval: timeInterval,
      repeats: true) { _ in action() }
    self.timer = timer
    RunLoop.current.add(timer, forMode: .common)
  }

  /**
   Stop the timer.

   停止计时器。
   */
  func stop() {
    timer?.invalidate()
    timer = nil
    startDate = nil
  }
}

extension RepeatGestureTimer {
  /// 修改计时器启动时间
  func modifyStartDate(to date: Date) {
    startDate = date
  }
}
