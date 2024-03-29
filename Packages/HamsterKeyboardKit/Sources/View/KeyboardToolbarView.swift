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
  private var style: CandidateBarStyle
  private var userInterfaceStyle: UIUserInterfaceStyle
  private var oldBounds: CGRect = .zero
  private var subscriptions = Set<AnyCancellable>()

  /// 常用功能项: 仓输入法App
  lazy var iconButton: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "r.circle"), for: .normal)
    button.setPreferredSymbolConfiguration(.init(font: .systemFont(ofSize: 18), scale: .default), forImageIn: .normal)
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
    button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
    button.setPreferredSymbolConfiguration(.init(font: .systemFont(ofSize: 18), scale: .default), forImageIn: .normal)
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
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if userInterfaceStyle != keyboardContext.colorScheme {
      userInterfaceStyle = keyboardContext.colorScheme
      setupAppearance()
      candidateBarView.setStyle(self.style)
    }
  }

  override func constructViewHierarchy() {
    addSubview(commonFunctionBar)
    if keyboardContext.displayAppIconButton {
      commonFunctionBar.addSubview(iconButton)
    }
    if keyboardContext.displayKeyboardDismissButton {
      commonFunctionBar.addSubview(dismissKeyboardButton)
    }
  }

  override func activateViewConstraints() {
    var constraints: [NSLayoutConstraint] = [
      commonFunctionBar.topAnchor.constraint(equalTo: topAnchor),
      commonFunctionBar.bottomAnchor.constraint(equalTo: bottomAnchor),
      commonFunctionBar.leadingAnchor.constraint(equalTo: leadingAnchor),
      commonFunctionBar.trailingAnchor.constraint(equalTo: trailingAnchor),
    ]

    if keyboardContext.displayAppIconButton {
      constraints.append(contentsOf: [
        iconButton.leadingAnchor.constraint(equalTo: commonFunctionBar.leadingAnchor),
        iconButton.heightAnchor.constraint(equalTo: iconButton.widthAnchor),
        iconButton.topAnchor.constraint(lessThanOrEqualTo: commonFunctionBar.topAnchor),
        commonFunctionBar.bottomAnchor.constraint(greaterThanOrEqualTo: iconButton.bottomAnchor),
        iconButton.centerYAnchor.constraint(equalTo: commonFunctionBar.centerYAnchor),
      ])
    }

    if keyboardContext.displayKeyboardDismissButton {
      constraints.append(contentsOf: [
        dismissKeyboardButton.heightAnchor.constraint(equalTo: dismissKeyboardButton.widthAnchor),
        dismissKeyboardButton.trailingAnchor.constraint(equalTo: commonFunctionBar.trailingAnchor),
        dismissKeyboardButton.topAnchor.constraint(lessThanOrEqualTo: commonFunctionBar.topAnchor),
        commonFunctionBar.bottomAnchor.constraint(greaterThanOrEqualTo: dismissKeyboardButton.bottomAnchor),
        dismissKeyboardButton.centerYAnchor.constraint(equalTo: commonFunctionBar.centerYAnchor),
      ])
    }

    NSLayoutConstraint.activate(constraints)
  }

  override func setupAppearance() {
    self.style = appearance.candidateBarStyle
    if keyboardContext.displayAppIconButton {
      iconButton.tintColor = style.toolbarButtonFrontColor
    }
    if keyboardContext.displayKeyboardDismissButton {
      dismissKeyboardButton.tintColor = style.toolbarButtonFrontColor
    }
  }

  func combine() {
    rimeContext.userInputKeyPublished
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        let isEmpty = $0.isEmpty
        self.commonFunctionBar.isHidden = !isEmpty
        self.candidateBarView.isHidden = isEmpty

        if self.candidateBarView.superview == nil {
          candidateBarView.setStyle(self.style)
          addSubview(candidateBarView)
          candidateBarView.fillSuperview()
        }

        // 检测是否启用内嵌编码
        guard !keyboardContext.enableEmbeddedInputMode else { return }
        if self.keyboardContext.keyboardType.isChineseNineGrid {
          // Debug
          // self.phoneticArea.text = inputKeys + " | " + self.rimeContext.t9UserInputKey
          candidateBarView.phoneticLabel.text = self.rimeContext.t9UserInputKey
        } else {
          candidateBarView.phoneticLabel.text = $0
        }
      }
      .store(in: &subscriptions)
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
    actionHandler.handle(.release, on: .url(URL(string: "hamster://dev.fuxiao.app.hamster/main"), id: "openHamster"))
  }

  @objc func touchCancel() {
    dismissKeyboardButton.backgroundColor = style.toolbarButtonBackgroundColor
    iconButton.backgroundColor = style.toolbarButtonBackgroundColor
  }
}
