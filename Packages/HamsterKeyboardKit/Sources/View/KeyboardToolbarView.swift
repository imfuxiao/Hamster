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
  private let actionHandler: KeyboardActionHandler
  private let keyboardContext: KeyboardContext
  private var rimeContext: RimeContext
  private var subscriptions = Set<AnyCancellable>()

  /// 常用功能项: 仓输入法App
  lazy var iconView: UIView = {
    let label = UILabel(frame: .zero)
    label.text = "㞢"
    label.adjustsFontSizeToFitWidth = true
    label.textAlignment = .center
    label.textColor = keyboardContext.secondaryLabelColor
    return label
  }()

  lazy var dismissKeyboardView: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clearInteractable

    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)
    let imageView = UIImageView(image: .init(systemName: "chevron.down.square", withConfiguration: config))
    imageView.tintColor = keyboardContext.secondaryLabelColor
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

    if !keyboardContext.enableHamsterKeyboardColor {
      view.backgroundColor = .systemGroupedBackground
    }

    return view
  }()

  /// 候选文字视图
  lazy var candidateWordView: UIView = {
    let view = CandidateWordsView(
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init(actionHandler: KeyboardActionHandler, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)

    Task {
      await rimeContext.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in
          let isEmpty = $0.isEmpty
          self.candidateWordView.isHidden = isEmpty
        }
        .store(in: &subscriptions)
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    setupSubview()
  }

  func setupSubview() {
    addSubview(commonFunctionBar)
    addSubview(candidateWordView)

    NSLayoutConstraint.activate([
      commonFunctionBar.topAnchor.constraint(equalTo: topAnchor),
      commonFunctionBar.bottomAnchor.constraint(equalTo: bottomAnchor),
      commonFunctionBar.leadingAnchor.constraint(equalTo: leadingAnchor),
      commonFunctionBar.trailingAnchor.constraint(equalTo: trailingAnchor),

      candidateWordView.topAnchor.constraint(equalTo: topAnchor),
      candidateWordView.bottomAnchor.constraint(equalTo: bottomAnchor),
      candidateWordView.leadingAnchor.constraint(equalTo: leadingAnchor),
      candidateWordView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    commonFunctionBar.isHidden = true
    candidateWordView.isHidden = true
  }

  @objc func dismissKeyboardAction() {
    actionHandler.handle(.release, on: .dismissKeyboard)
  }
}
