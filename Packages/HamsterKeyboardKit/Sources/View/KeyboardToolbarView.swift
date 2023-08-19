//
//  KeyboardToolbarView.swift
//
//
//  Created by morse on 2023/8/19.
//

import UIKit

/**
 键盘工具栏

 用于显示：
 1. 候选文字，包含横向部分文字显示及下拉显示全部文字
 2. 常用功能视图
 */
class KeyboardToolbarView: UIView {
  private var keyboardContext: KeyboardContext

  /// 常用功能栏
  lazy var commonFunctionBar: UIView = {
    let view = UIView()
    return view
  }()

  // TODO: 候选文字视图
  lazy var candidateWordView: UIView = {
    let view = CandidateWordsView(keyboardContext: keyboardContext)
    return view
  }()

  init(keyboardContext: KeyboardContext) {
    self.keyboardContext = keyboardContext

    super.init(frame: .zero)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    addSubview(candidateWordView)
    candidateWordView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      candidateWordView.topAnchor.constraint(equalTo: topAnchor),
      candidateWordView.bottomAnchor.constraint(equalTo: bottomAnchor),
      candidateWordView.leadingAnchor.constraint(equalTo: leadingAnchor),
      candidateWordView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}
