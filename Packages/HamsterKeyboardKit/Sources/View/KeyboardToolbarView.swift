//
//  KeyboardToolbarView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import HamsterUIKit
import UIKit

/**
 键盘工具栏

 用于显示：
 1. 候选文字，包含横向部分文字显示及下拉显示全部文字
 2. 常用功能视图
 */
class KeyboardToolbarView: NibLessView {
  private let appearance: KeyboardAppearance
  private let actionHandler: KeyboardActionHandler
  private let keyboardContext: KeyboardContext
  private var rimeContext: RimeContext
  private var subscriptions = Set<AnyCancellable>()
  private var style: CandidateBarStyle
  private var userInterfaceStyle: UIUserInterfaceStyle

  /// 常用功能项: 仓输入法App
  lazy var iconButton: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "r.square"), for: .normal)
    button.setPreferredSymbolConfiguration(.init(font: .systemFont(ofSize: 20), scale: .large), forImageIn: .normal)
    button.tintColor = style.toolbarButtonFrontColor
    button.backgroundColor = style.toolbarButtonBackgroundColor
    button.addTarget(self, action: #selector(openHamsterAppTouchDownAction), for: .touchDown)
    button.addTarget(self, action: #selector(openHamsterAppTouchUpAction), for: .touchUpInside)
    button.addTarget(self, action: #selector(touchCancel), for: .touchCancel)
    button.addTarget(self, action: #selector(touchCancel), for: .touchUpOutside)

    return button
  }()

  /// 解散键盘 Button
  lazy var dismissKeyboardButton: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "arrowtriangle.down.square"), for: .normal)
    button.setPreferredSymbolConfiguration(.init(font: .systemFont(ofSize: 20), scale: .large), forImageIn: .normal)
    button.tintColor = style.toolbarButtonFrontColor
    button.backgroundColor = style.toolbarButtonBackgroundColor
    button.addTarget(self, action: #selector(dismissKeyboardTouchDownAction), for: .touchDown)
    button.addTarget(self, action: #selector(dismissKeyboardTouchUpAction), for: .touchUpInside)
    button.addTarget(self, action: #selector(touchCancel), for: .touchCancel)
    button.addTarget(self, action: #selector(touchCancel), for: .touchUpOutside)
    return button
  }()

  // TODO: 常用功能栏
  lazy var commonFunctionBar: UIView = {
    let view = UIView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false

    var constraints = [NSLayoutConstraint]()
    if keyboardContext.displayAppIconButton {
      view.addSubview(iconButton)
      constraints.append(contentsOf: [
        iconButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        iconButton.heightAnchor.constraint(equalTo: iconButton.widthAnchor),
        iconButton.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor),
        view.bottomAnchor.constraint(greaterThanOrEqualTo: iconButton.bottomAnchor),
        iconButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      ])
    }

    if keyboardContext.displayKeyboardDismissButton {
      view.addSubview(dismissKeyboardButton)
      constraints.append(contentsOf: [
        dismissKeyboardButton.heightAnchor.constraint(equalTo: dismissKeyboardButton.widthAnchor),
        dismissKeyboardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        dismissKeyboardButton.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor),
        view.bottomAnchor.constraint(greaterThanOrEqualTo: dismissKeyboardButton.bottomAnchor),
        dismissKeyboardButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      ])
    }

    if !constraints.isEmpty {
      NSLayoutConstraint.activate(constraints)
    }

    return view
  }()

  /// 候选文字视图
  lazy var candidateBarView: CandidateBarView = {
    let view = CandidateBarView(
      style: style,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init(appearance: KeyboardAppearance, actionHandler: KeyboardActionHandler, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.appearance = appearance
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext
    // KeyboardToolbarView 为 candidateBarStyle 样式根节点, 这里生成一次，减少计算次数
    self.style = appearance.candidateBarStyle
    self.userInterfaceStyle = keyboardContext.colorScheme

    super.init(frame: .zero)

    setupSubview()

    combine()
  }

  func setupSubview() {
    constructViewHierarchy()
    activateViewConstraints()
    setupAppearance()
    commonFunctionBar.isHidden = false
    candidateBarView.isHidden = true
  }

  override func constructViewHierarchy() {
    addSubview(commonFunctionBar)
    addSubview(candidateBarView)
  }

  override func activateViewConstraints() {
    NSLayoutConstraint.activate([
      commonFunctionBar.topAnchor.constraint(equalTo: topAnchor),
      commonFunctionBar.bottomAnchor.constraint(equalTo: bottomAnchor),
      commonFunctionBar.leadingAnchor.constraint(equalTo: leadingAnchor),
      commonFunctionBar.trailingAnchor.constraint(equalTo: trailingAnchor),

      candidateBarView.topAnchor.constraint(equalTo: topAnchor),
      candidateBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
      candidateBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
      candidateBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  override func setupAppearance() {
    self.style = appearance.candidateBarStyle
    candidateBarView.setStyle(style)
    // TODO: 工具栏其他 view 更新 style
    iconButton.tintColor = style.toolbarButtonFrontColor
    dismissKeyboardButton.tintColor = style.toolbarButtonFrontColor
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if userInterfaceStyle != keyboardContext.colorScheme {
      userInterfaceStyle = keyboardContext.colorScheme
      setupAppearance()
    }
  }

  func combine() {
    Task {
      await rimeContext.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in
          let isEmpty = $0.isEmpty
          self.candidateBarView.isHidden = isEmpty
          self.commonFunctionBar.isHidden = !isEmpty
        }
        .store(in: &subscriptions)
    }
  }

  @objc func dismissKeyboardTouchDownAction() {
    dismissKeyboardButton.backgroundColor = style.toolbarButtonPressedBackgroundColor
  }

  @objc func dismissKeyboardTouchUpAction() {
    dismissKeyboardButton.backgroundColor = style.toolbarButtonBackgroundColor
    actionHandler.handle(.release, on: .dismissKeyboard)
  }

  @objc func openHamsterAppTouchDownAction() {
    iconButton.backgroundColor = style.toolbarButtonPressedBackgroundColor
  }

  @objc func openHamsterAppTouchUpAction() {
    iconButton.backgroundColor = style.toolbarButtonPressedBackgroundColor
    actionHandler.handle(.release, on: .url(URL(string: "hamster://"), id: "openHamster"))
  }

  @objc func touchCancel() {
    dismissKeyboardButton.backgroundColor = style.toolbarButtonBackgroundColor
    iconButton.backgroundColor = style.toolbarButtonBackgroundColor
  }
}
