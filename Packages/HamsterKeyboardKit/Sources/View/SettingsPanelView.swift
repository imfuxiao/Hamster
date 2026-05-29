//
//  SettingsPanelView.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import HamsterUIKit
import UIKit

/// 设置面板视图
class SettingsPanelView: NibLessView {
  private let style: CandidateBarStyle

  lazy var stackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.spacing = 16
    return stack
  }()

  init(style: CandidateBarStyle) {
    self.style = style
    super.init(frame: .zero)
    setupSubview()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubview() {
    backgroundColor = style.toolbarButtonBackgroundColor

    // 创建三个卡片
    let aiCard = SettingsCardView(iconName: "key", title: "AI Key")
    let gifCard = SettingsCardView(iconName: "photo", title: "GIF Key")
    let playCard = SettingsCardView(iconName: "play.circle", title: "文字播放")

    stackView.addArrangedSubview(aiCard)
    stackView.addArrangedSubview(gifCard)
    stackView.addArrangedSubview(playCard)

    addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])
  }
}
