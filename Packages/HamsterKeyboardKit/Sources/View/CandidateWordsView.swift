//
//  CandidateWordsView.swift
//
//
//  Created by morse on 2023/8/19.
//

import UIKit

/**
 候选文字视图
 */
class CandidateWordsView: UIView {
  private var keyboardContext: KeyboardContext

  /// 拼音区域
  lazy var phoneticArea: UIView = {
    let view = UIView(frame: .zero)

    view.backgroundColor = .blue
    return view
  }()

  /// 候选文字区域
  lazy var candidatesArea: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .yellow
    return view
  }()

  /// 布局配置
  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  init(keyboardContext: KeyboardContext) {
    self.keyboardContext = keyboardContext

    super.init(frame: .zero)

    setupContentView()
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
    // TODO: 高度可按配置调整
    NSLayoutConstraint.activate([
      phoneticArea.heightAnchor.constraint(equalToConstant: 15),
      phoneticArea.topAnchor.constraint(equalTo: topAnchor, constant: buttonInsets.top),
      phoneticArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
      phoneticArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),

      candidatesArea.heightAnchor.constraint(equalToConstant: 45),
      candidatesArea.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor, constant: buttonInsets.top),
      candidatesArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -buttonInsets.bottom),
      candidatesArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
      candidatesArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),
    ])
  }

  func setupContentView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    activateViewConstraints()
  }
}
