//
//  CandidateWordsView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import UIKit

/**
 候选文字视图
 */
class CandidateWordsView: UIView {
  private var actionHandler: KeyboardActionHandler
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  private var subscription = Set<AnyCancellable>()
  /// 拼音区域
  lazy var phoneticArea: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    if let fontSize = keyboardContext.hamsterConfig?.toolbar?.codingAreaFontSize {
      label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
    }

    // 开启键盘配色
    if keyboardContext.hamsterConfig?.Keyboard?.enableColorSchema ?? false, let keyboardColor = keyboardContext.hamsterKeyboardColor {
      label.textColor = keyboardColor.textColor
    }

    return label
  }()

  /// 候选文字区域
  lazy var candidatesArea: CandidateWordsCollectionView = {
    let view = CandidateWordsCollectionView(
      keyboardContext: keyboardContext,
      actionHandler: actionHandler,
      rimeContext: rimeContext,
      direction: .horizontal)
    return view
  }()

  /// 布局配置
  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  init(actionHandler: KeyboardActionHandler, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)

    setupContentView()
    combine()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 构建视图层次
  func constructViewHierarchy() {
    addSubview(phoneticArea)
    addSubview(candidatesArea)
  }

  /// 激活视图约束
  func activateViewConstraints() {
    phoneticArea.translatesAutoresizingMaskIntoConstraints = false
    candidatesArea.translatesAutoresizingMaskIntoConstraints = false

    let buttonInsets = layoutConfig.buttonInsets
    let codingAreaHeight = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfCodingArea ?? 15)

    NSLayoutConstraint.activate([
      phoneticArea.heightAnchor.constraint(equalToConstant: codingAreaHeight),
      phoneticArea.topAnchor.constraint(equalTo: topAnchor),
      phoneticArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
      phoneticArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),

      candidatesArea.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor),
      candidatesArea.bottomAnchor.constraint(equalTo: bottomAnchor),
      candidatesArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
      candidatesArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),
    ])
  }

  func setupContentView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  func combine() {
    Task {
      await rimeContext.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [weak self] inputKeys in
          guard let self = self else { return }
          self.phoneticArea.text = inputKeys
        }
        .store(in: &subscription)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    activateViewConstraints()
  }
}
