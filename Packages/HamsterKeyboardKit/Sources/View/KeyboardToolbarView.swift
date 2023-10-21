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
  lazy var iconView: UIView = {
    let label = UILabel(frame: .zero)
    label.text = "㞢"
    label.adjustsFontSizeToFitWidth = true
    label.textAlignment = .center
    return label
  }()

  lazy var dismissKeyboardView: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clearInteractable

    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)
    let imageView = UIImageView(image: .init(systemName: "chevron.down.square", withConfiguration: config))
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(imageView)

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction)))
    return view
  }()

  // TODO: 常用功能栏
  lazy var commonFunctionBar: UIView = {
    let view = UIStackView(arrangedSubviews: [iconView, dismissKeyboardView])
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .equalSpacing
    view.spacing = 0
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
    commonFunctionBar.isHidden = true
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
        }
        .store(in: &subscriptions)
    }
  }

  @objc func dismissKeyboardAction() {
    actionHandler.handle(.release, on: .dismissKeyboard)
  }
}
