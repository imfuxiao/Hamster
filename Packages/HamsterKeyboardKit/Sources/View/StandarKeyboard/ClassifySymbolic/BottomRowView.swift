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
    button.addTarget(self, action: #selector(returnHandled), for: .touchUpInside)
    button.backgroundColor = .systemBlue
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var lockStateButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "lock"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var backspaceButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "delete.left"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
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
    var buttonWidthPercent: CGFloat = 0.25
    if let layoutProvider = layoutProvider as? SystemKeyboardLayoutProvider, case .percentage(let percent) = layoutProvider.largeBottomWidth(for: keyboardContext) {
      buttonWidthPercent = percent
    } else {
      Logger.statistics.warning("get largeBottomWidth is empty")
    }

    NSLayoutConstraint.activate([
      returnButton.topAnchor.constraint(equalTo: topAnchor),
      returnButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      returnButton.leadingAnchor.constraint(equalTo: leadingAnchor),

      lockStateButton.topAnchor.constraint(equalTo: topAnchor),
      lockStateButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      lockStateButton.leadingAnchor.constraint(equalTo: returnButton.trailingAnchor),

      backspaceButton.topAnchor.constraint(equalTo: topAnchor),
      backspaceButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      backspaceButton.leadingAnchor.constraint(equalTo: lockStateButton.trailingAnchor),
      backspaceButton.trailingAnchor.constraint(equalTo: trailingAnchor),

      returnButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: buttonWidthPercent),
      backspaceButton.widthAnchor.constraint(equalTo: returnButton.widthAnchor)
    ])
  }
}

extension BottomRowView {
  @objc func returnHandled() {
    // TODO: 返回之前键盘
    actionHandler.handle(.press, on: .keyboardType(.chinese(.auto)))
  }
}
