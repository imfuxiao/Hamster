//
//  SettingsCardView.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import HamsterUIKit
import UIKit

/// 设置卡片视图
class SettingsCardView: NibLessView {
  private let iconName: String
  private let title: String

  lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .label
    return imageView
  }()

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12, weight: .medium)
    label.textAlignment = .center
    label.textColor = .label
    return label
  }()

  init(iconName: String, title: String) {
    self.iconName = iconName
    self.title = title
    super.init(frame: .zero)
    setupSubview()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubview() {
    iconImageView.image = UIImage(systemName: iconName)
    titleLabel.text = title

    addSubview(iconImageView)
    addSubview(titleLabel)

    NSLayoutConstraint.activate([
      iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: 32),
      iconImageView.heightAnchor.constraint(equalToConstant: 32),

      titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
    ])
  }
}
