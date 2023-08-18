//
//  KeyboardTouchView.swift
//
//
//  Created by morse on 2023/8/17.
//

import HamsterKit
import OSLog
import UIKit

/**
 按键触控处理

 注意：需要将所有按键添加至此 view 中，作为此 view 的 subview
 */
class KeyboardTouchView: UIView {
  // MARK: - Initializations

  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Touch 处理

  /**
   返回视图层次结构（包括其自身）中包含指定 point 的接收者的最远后代。
   */
//  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//    print("\n Keyboard Touch view hitTest \n")
//    return bounds.contains(point) ? self : nil
//  }

//
//  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    for touch in touches {
//      // 返回 touch 在给定视图坐标系中的当前位置。
//      Logger.statistics.debug("touch began \(touch.view?.debugDescription)")
//      let point = touch.location(in: self)
//      guard let subview = findNearestView(point) else { continue }
//      Logger.statistics.debug("touch view \(subview.debugDescription)")
//      self.handleControl(subview, controlEvent: .touchDown)
//    }
//  }
//
//  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//    Logger.statistics.debug("touchesMoved")
//  }
//
//  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    Logger.statistics.debug("touchesEnded")
//  }
//
//  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//    Logger.statistics.debug("touchesCancelled")
//  }
//
//  // 手势控制处理
//  func handleControl(_ view: UIView, controlEvent: UIControl.Event) {
//    guard let controlView = view as? UIControl else { return }
//    let targets = controlView.allTargets
//    for target in targets {
//      if let actions = controlView.actions(forTarget: target, forControlEvent: controlEvent) {
//        for action in actions {
//          let selectorString = action
//          let selector = Selector(selectorString)
//          controlView.sendAction(selector, to: target, for: nil)
//        }
//      }
//    }
//  }

  /// 查找 position 最近的子视图
  func findNearestView(_ point: CGPoint) -> UIView? {
    guard bounds.contains(point) else { return nil }

    var closest: (UIView, CGFloat)?

    for anyView in subviews {
      let view = anyView
      if view.isHidden {
        continue
      }

//      view.alpha = 1

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
  /// 距离 point 的距离
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
