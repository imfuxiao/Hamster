//
//  BottomRowView.swift
//
//
//  Created by morse on 2023/9/5.
//

import HamsterKit
import OSLog
import UIKit

/// 底部行
class BottomRowView: UIView {
  private let actionHandler: KeyboardActionHandler
  private let layoutProvider: KeyboardLayoutProvider
  private let keyboardContext: KeyboardContext
  private var returnButtonWidthConstraint: NSLayoutConstraint? = nil

  init(
    actionHandler: KeyboardActionHandler,
    layoutProvider: KeyboardLayoutProvider,
    keyboardContext: KeyboardContext
  ) {
    self.actionHandler = actionHandler
    self.layoutProvider = layoutProvider
    self.keyboardContext = keyboardContext

    super.init(frame: .zero)

    constructViewHierarchy()
    activateViewConstraints()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var returnButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("返回", for: .normal)
    button.tintColor = keyboardContext.secondaryLabelColor
    button.backgroundColor = keyboardContext.systemButtonBackgroundColor
    button.addTarget(self, action: #selector(returnKeyboardPressHandled(_:)), for: .touchDown)
    button.addTarget(self, action: #selector(returnKeyboardReleaseHandled(_:)), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  // 锁定状态
  lazy var lockStateButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: keyboardContext.classifySymbolKeyboardLockState ? "lock" : "lock.open"), for: .normal)
    button.tintColor = keyboardContext.secondaryLabelColor
    button.backgroundColor = keyboardContext.backgroundColor
    button.addTarget(self, action: #selector(lockStatePressHandled(_:)), for: .touchDown)
    button.addTarget(self, action: #selector(lockStateReleaseHandled(_:)), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var backspaceButton: UIButton = {
    let button = UIButton(type: .custom)
    button.tintColor = keyboardContext.secondaryLabelColor
    button.setImage(UIImage(systemName: "delete.left"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.tintColor = .label
    button.addTarget(self, action: #selector(backspacePressHandled(_:)), for: .touchDown)
    button.addTarget(self, action: #selector(backspaceReleaseHandled(_:)), for: .touchUpInside)
    return button
  }()

  /// 构建视图层次
  func constructViewHierarchy() {
    addSubview(returnButton)
    addSubview(lockStateButton)
    addSubview(backspaceButton)
  }

  /// 激活视图约束
  func activateViewConstraints() {
    // TODO: 这里获取不到值
    returnButtonWidthConstraint = returnButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: keyboardContext.interfaceOrientation.isPortrait ? 0.2 : 0.1)

    NSLayoutConstraint.activate([
      returnButton.topAnchor.constraint(equalTo: topAnchor),
      returnButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      returnButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      returnButtonWidthConstraint!,

      lockStateButton.topAnchor.constraint(equalTo: topAnchor),
      lockStateButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      lockStateButton.leadingAnchor.constraint(equalTo: returnButton.trailingAnchor),

      backspaceButton.topAnchor.constraint(equalTo: topAnchor),
      backspaceButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      backspaceButton.leadingAnchor.constraint(equalTo: lockStateButton.trailingAnchor),
      backspaceButton.trailingAnchor.constraint(equalTo: trailingAnchor),

      backspaceButton.widthAnchor.constraint(equalTo: returnButton.widthAnchor)
    ])
  }

  override func updateConstraints() {
    super.updateConstraints()

    returnButtonWidthConstraint?.isActive = false
    returnButtonWidthConstraint = returnButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: keyboardContext.interfaceOrientation.isPortrait ? 0.2 : 0.1)
    returnButtonWidthConstraint?.isActive = true
  }
}

extension BottomRowView {
  @objc func returnKeyboardPressHandled(_ button: UIButton) {
    actionHandler.handle(.press, on: .returnLastKeyboard)
  }

  @objc func returnKeyboardReleaseHandled(_ button: UIButton) {
    actionHandler.handle(.release, on: .returnLastKeyboard)
  }

  @objc func lockStatePressHandled(_ button: UIButton) {
    actionHandler.handle(.press, on: .none)
  }

  @objc func lockStateReleaseHandled(_ button: UIButton) {
    let state = keyboardContext.classifySymbolKeyboardLockState
    button.setImage(UIImage(systemName: state ? "lock.open" : "lock"), for: .normal)
    keyboardContext.classifySymbolKeyboardLockState = !state
  }

  @objc func backspacePressHandled(_ button: UIButton) {
    button.backgroundColor = .white
    actionHandler.handle(.press, on: .backspace)
  }

  @objc func backspaceReleaseHandled(_ button: UIButton) {
    button.backgroundColor = keyboardContext.systemButtonBackgroundColor
    actionHandler.handle(.release, on: .backspace)
  }
}
