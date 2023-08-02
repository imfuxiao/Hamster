//
//  ButtonTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import HamsterUIKit
import UIKit

public class ButtonTableViewCell: NibLessTableViewCell {
  static let identifier = "ButtonTableCell"

  // MARK: properties

  let buttonView: UIButton = {
    let button = UIButton(type: .roundedRect)
    return button
  }()

  public var settingItem: SettingItemModel {
    didSet {
      buttonView.setTitle(settingItem.text, for: .normal)
      buttonView.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
      if let textTintColor = settingItem.textTintColor {
        buttonView.titleLabel?.tintColor = textTintColor
      }
      buttonView.addTarget(self, action: #selector(buttonHandled), for: .touchUpInside)
    }
  }

  // MARK: methods

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.settingItem = SettingItemModel()

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupButtonView()
  }

  func setupButtonView() {
    contentView.addSubview(buttonView)
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      buttonView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonView.bottomAnchor, multiplier: 1.0),
      buttonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      buttonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])
  }

  @objc func buttonHandled() {
    // TODO: 异常处理
    do {
      try settingItem.buttonAction?()
    } catch {
      print(error)
    }
  }
}
