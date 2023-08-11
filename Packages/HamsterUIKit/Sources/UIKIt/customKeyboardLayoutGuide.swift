//
//  Keyboard+LayoutGuide.swift
//  KeyboardLayoutGuide
//
//  Created by Sacha DSO on 14/11/2017.
//  Copyright © 2017 freshos. All rights reserved.
//

/// 修复 iOS14 无 keyboardLayoutGuide
/// 代码来源: https://github.com/freshOS/KeyboardLayoutGuide
// import UIKit
//
// internal class Keyboard {
//  static let shared = Keyboard()
//  var currentHeight: CGFloat = 0
// }
//
// extension UIView {
//  private enum Identifiers {
//    static var usingSafeArea = "CustomKeyboardLayoutGuideUsingSafeArea"
//    static var notUsingSafeArea = "CustomKeyboardLayoutGuide"
//  }
//
//  /// A layout guide representing the inset for the keyboard.
//  /// Use this layout guide’s top anchor to create constraints pinning to the top of the keyboard or the bottom of safe area.
//  public var customKeyboardLayoutGuide: UILayoutGuide {
//    getOrCreateKeyboardLayoutGuide(identifier: Identifiers.usingSafeArea, usesSafeArea: true)
//  }
//
//  /// A layout guide representing the inset for the keyboard.
//  /// Use this layout guide’s top anchor to create constraints pinning to the top of the keyboard or the bottom of the view.
//  public var customKeyboardLayoutGuideNoSafeArea: UILayoutGuide {
//    getOrCreateKeyboardLayoutGuide(identifier: Identifiers.notUsingSafeArea, usesSafeArea: false)
//  }
//
//  private func getOrCreateKeyboardLayoutGuide(identifier: String, usesSafeArea: Bool) -> UILayoutGuide {
//    if let existing = layoutGuides.first(where: { $0.identifier == identifier }) {
//      return existing
//    }
//    let new = HamsterCustomKeyboardLayoutGuide()
//    new.usesSafeArea = usesSafeArea
//    new.identifier = identifier
//    addLayoutGuide(new)
//    new.setUp()
//    return new
//  }
// }
//
// open class HamsterCustomKeyboardLayoutGuide: UILayoutGuide {
//  public var usesSafeArea = true {
//    didSet {
//      updateBottomAnchor()
//    }
//  }
//
//  private var bottomConstraint: NSLayoutConstraint?
//
//  @available(*, unavailable)
//  public required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  public init(notificationCenter: NotificationCenter = NotificationCenter.default) {
//    super.init()
//    // Observe keyboardWillChangeFrame notifications
//    notificationCenter.addObserver(
//      self,
//      selector: #selector(adjustKeyboard(_:)),
//      name: UIResponder.keyboardWillChangeFrameNotification,
//      object: nil
//    )
//    // Observe keyboardWillHide notifications
//    notificationCenter.addObserver(
//      self,
//      selector: #selector(adjustKeyboard(_:)),
//      name: UIResponder.keyboardWillHideNotification,
//      object: nil
//    )
//  }
//
//  internal func setUp() {
//    guard let view = owningView else { return }
//    NSLayoutConstraint.activate(
//      [
//        heightAnchor.constraint(equalToConstant: Keyboard.shared.currentHeight),
//        leftAnchor.constraint(equalTo: view.leftAnchor),
//        rightAnchor.constraint(equalTo: view.rightAnchor),
//      ]
//    )
//    updateBottomAnchor()
//  }
//
//  func updateBottomAnchor() {
//    if let bottomConstraint = bottomConstraint {
//      bottomConstraint.isActive = false
//    }
//
//    guard let view = owningView else { return }
//
//    let viewBottomAnchor: NSLayoutYAxisAnchor
//    if #available(iOS 11.0, *), usesSafeArea {
//      viewBottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
//    } else {
//      viewBottomAnchor = view.bottomAnchor
//    }
//
//    bottomConstraint = bottomAnchor.constraint(equalTo: viewBottomAnchor)
//    bottomConstraint?.isActive = true
//  }
//
//  @objc
//  private func adjustKeyboard(_ note: Notification) {
//    if var height = note.keyboardHeight, let duration = note.animationDuration {
//      if #available(iOS 11.0, *), usesSafeArea, height > 0, let bottom = owningView?.safeAreaInsets.bottom {
//        height -= bottom
//      }
//      heightConstraint?.constant = height
//      if duration > 0.0 {
//        animate(note)
//      }
//      Keyboard.shared.currentHeight = height
//    }
//  }
//
//  private func animate(_ note: Notification) {
//    if
//      let owningView = owningView,
//      isVisible(view: owningView)
//    {
//      self.owningView?.layoutIfNeeded()
//    } else {
//      UIView.performWithoutAnimation {
//        self.owningView?.layoutIfNeeded()
//      }
//    }
//  }
// }
//
//// MARK: - Helpers
//
// extension UILayoutGuide {
//  var heightConstraint: NSLayoutConstraint? {
//    return owningView?.constraints.first {
//      $0.firstItem as? UILayoutGuide == self && $0.firstAttribute == .height
//    }
//  }
// }
//
// extension Notification {
//  var keyboardHeight: CGFloat? {
//    guard let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
//      return nil
//    }
//
//    if name == UIResponder.keyboardWillHideNotification {
//      return 0.0
//    } else {
//      // Weirdly enough UIKeyboardFrameEndUserInfoKey doesn't have the same behaviour
//      // in ios 10 or iOS 11 so we can't rely on v.cgRectValue.width
////      let screenHeight = UIApplication.shared.keyWindow?.bounds.height ?? UIScreen.main.bounds.height
//      // https://stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
//      let screenHeight = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.bounds.height ?? UIScreen.main.bounds.height
//      return screenHeight - keyboardFrame.cgRectValue.minY
//    }
//  }
//
//  var animationDuration: CGFloat? {
//    return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat
//  }
// }
//
//// Credits to John Gibb for this nice helper :)
//// https://stackoverflow.com/questions/1536923/determine-if-uiview-is-visible-to-the-user
// func isVisible(view: UIView) -> Bool {
//  func isVisible(view: UIView, inView: UIView?) -> Bool {
//    guard let inView = inView else { return true }
//    let viewFrame = inView.convert(view.bounds, from: view)
//    if viewFrame.intersects(inView.bounds) {
//      return isVisible(view: view, inView: inView.superview)
//    }
//    return false
//  }
//  return isVisible(view: view, inView: view.superview)
// }
