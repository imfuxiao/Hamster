//
//  KeyboardTouchView.swift
//
//
//  Created by morse on 2023/8/17.
//

import HamsterKit
import HamsterUIKit
import OSLog
import UIKit

/**
 按键触控处理

 注意：需要将所有按键添加至此 view 中，作为此 view 的 subview
 */
public class KeyboardTouchView: NibLessView {
  // MARK: - Initializations

  enum ButtonEvent {
    case press
    case drag
    case release
    case cancel
  }

  /// UITouch 所属的按键
  private var touchOnButton: [UITouch: UIView] = [:]

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.isMultipleTouchEnabled = true
    self.isUserInteractionEnabled = true
  }

  // MARK: - Touch 处理

  /**
   只有 button 类型的触控响应指定为自己
   */
  override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if self.isHidden || self.alpha < 0.01 || !self.isUserInteractionEnabled {
      return nil
    }
    guard bounds.contains(point) else { return nil }

    if let view = findNearestView(point) {
      if let button = view as? KeyboardButton {
        if button.item.action == .nextKeyboard {
          return button
        }
        return self
      }
    }
    return super.hitTest(point, with: event)
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      // 返回 touch 在给定视图坐标系中的当前位置。
      let point = touch.location(in: self)
      guard let button = findNearestView(point) else { continue }
      guard touchOwnership(touch, button: button) else { continue }

      // 未释放的旧按键被新按键顶替
      if touchOnButton.keys.count > 1, let otherTouch = touchOnButton.keys.first(where: { $0 != touch }) {
        if let otherButton = touchOnButton[otherTouch], otherButton != button {
          touchOnButton[otherTouch] = nil
          self.handleButtonEvent(otherButton, buttonEvent: .release, touch: otherTouch, event: event)
        }
      }

      self.handleButtonEvent(button, buttonEvent: .press, touch: touch, event: event)
    }
  }

  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      // let point = touch.location(in: self)
      // guard let newView = self.findNearestView(point) else { continue }
      let oldView = self.touchOnButton[touch]
      if let oldView = oldView {
        self.handleButtonEvent(oldView, buttonEvent: .drag, touch: touch, event: event)
      }

      // TODO: 其他滑动处理
//      if oldView == newView {
//        self.handleButtonEvent(newView, event: .drag, touch: touch)
//        continue
//      }
//
//      _ = touchOwnership(touch, button: newView)
//      self.handleButtonEvent(newView, event: .drag, touch: touch)

//      if touchOwnership(touch, button: newView) {
//        self.handleButtonEvent(newView, event: .press, touch: touch)
//      } else {
//      }
    }
  }

  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      guard let view = self.touchOnButton[touch] else { continue }
      self.handleButtonEvent(view, buttonEvent: .release, touch: touch, event: event)
      self.touchOnButton[touch] = nil
    }
  }

  override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      guard let view = self.touchOnButton[touch] else { continue }
      self.handleButtonEvent(view, buttonEvent: .release, touch: touch, event: event)
      self.touchOnButton[touch] = nil
    }
  }

  /// 记录 touch 与 view 的关系，如果 view 之前存在 touch 关联，则返回 false, 否则返回 true
  /// O(N): N 表示一次完整的 touch 事件经历的全部 UIView，所以 for 循环还可接受
  func touchOwnership(_ newTouch: UITouch, button newButton: UIView) -> Bool {
    var result = true
    for (oldTouch, oldButton) in touchOnButton {
      if oldButton == newButton {
        guard oldTouch != newTouch else { return false }
        touchOnButton.removeValue(forKey: oldTouch)
        result = false
        break
      }
    }
    touchOnButton[newTouch] = newButton
    return result
  }

  /// 按键触控处理
  func handleButtonEvent(_ view: UIView, buttonEvent: ButtonEvent, touch: UITouch, event: UIEvent?) {
    guard let button = view as? KeyboardButton else { return }
    switch buttonEvent {
    case .press:
      button.isHighlighted = true
      button.tryHandlePress(touch, event: event)
    case .drag:
      button.isHighlighted = true
      button.tryHandleDrag(touch, event: event)
    case .release:
      button.isHighlighted = false
      button.tryHandleRelease(touch, event: event)
    case .cancel:
      button.isHighlighted = false
      button.tryHandleCancel()
    }
  }

  /// 查找触控点最近的按键
  /// O(N): N 表示按键数量
  func findNearestView(_ point: CGPoint) -> UIView? {
    guard bounds.contains(point) else { return nil }

    var closest: (UIView, CGFloat)?

    for anyView in subviews {
      let view = anyView
      let distance = view.frame.distance(point)

      if closest != nil {
        if distance < closest!.1 {
          closest = (view, distance)
        }
      } else {
        closest = (view, distance)
      }
    }

    if closest != nil {
      return closest!.0
    } else {
      return nil
    }
  }
}

private extension CGRect {
  /// 距离 point 的直线距离
  /// http://stackoverflow.com/questions/3552108/finding-closest-object-to-cgpoint
  func distance(_ point: CGPoint) -> CGFloat {
    guard !contains(point) else { return 0 }

    var closest = origin

    if origin.x + size.width < point.x {
      closest.x += size.width
    } else if point.x > origin.x {
      closest.x = point.x
    }
    if origin.y + size.height < point.y {
      closest.y += size.height
    } else if point.y > origin.y {
      closest.y = point.y
    }

    let a = pow(Double(closest.y - point.y), 2)
    let b = pow(Double(closest.x - point.x), 2)
    return CGFloat(sqrt(a + b))
  }
}
