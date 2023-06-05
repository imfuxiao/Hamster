//
//  ButtonTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
  static let identifier = "ButtonTableCell"

  init(text: String, textTintColor: UIColor? = nil, buttonAction: @escaping () -> Void) {
    self.text = text
    self.textTintColor = textTintColor
    self.buttonAction = buttonAction
    super.init(style: .default, reuseIdentifier: Self.identifier)

    let button = buttonView
    button.addTarget(self, action: #selector(buttonHandled), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(button)
    NSLayoutConstraint.activate([
      button.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 1.0),
      button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var text = ""
  var textTintColor: UIColor?
  var buttonAction: () -> Void

  lazy var buttonView: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setTitle(text, for: .normal)
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    if let textTintColor = textTintColor {
      button.titleLabel?.tintColor = textTintColor
    }
    return button
  }()

  @objc func buttonHandled() {
    buttonAction()
  }
}
