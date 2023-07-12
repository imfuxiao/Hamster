//
//  ButtonTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import HamsterUIKit
import UIKit

private class ButtonView: NibLessView, UIContextMenuInteractionDelegate {
  // MARK: properties

  private let settingItem: SettingItemModel

  lazy var buttonView: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setTitle(settingItem.text, for: .normal)
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    if let textTintColor = settingItem.textTintColor {
      button.titleLabel?.tintColor = textTintColor
    }
    button.addTarget(self, action: #selector(buttonHandled), for: .touchUpInside)
    return button
  }()

  // MARK: methods

  init(frame: CGRect = .zero, settingItem: SettingItemModel) {
    self.settingItem = settingItem

    super.init(frame: frame)

    let interaction = UIContextMenuInteraction(delegate: self)
    addInteraction(interaction)
  }

  @objc func buttonHandled() {
    settingItem.buttonAction?()
  }

  override func constructViewHierarchy() {
    addSubview(buttonView)
  }

  override func activateViewConstraints() {
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      buttonView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1.0),
      bottomAnchor.constraint(equalToSystemSpacingBelow: buttonView.bottomAnchor, multiplier: 1.0),
      buttonView.leadingAnchor.constraint(equalTo: leadingAnchor),
      buttonView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()
  }

  // MARK: implementation UIContextMenuInteractionDelegate

  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    guard let favoriteButton = settingItem.favoriteButton else { return nil }

    let exist = UserDefaults.standard.favoriteButtonExist(button: favoriteButton)
    return UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: nil,
      actionProvider: {
        _ in
        let favorites = UIAction(
          title: exist ? "移出首页" : "添加至首页",
          image: exist ? UIImage(systemName: "star.slash") : UIImage(systemName: "star")
        ) { [unowned self] _ in
          if exist {
            UserDefaults.standard.removeFavoriteButton(button: favoriteButton)
          } else {
            UserDefaults.standard.setFavoriteButton(button: favoriteButton)
          }
          self.settingItem.favoriteButtonHandler?()
        }
        return UIMenu(title: "", children: [favorites])
      }
    )
  }
}

public class ButtonTableViewCell: NibLessTableViewCell {
  static let identifier = "ButtonTableCell"

  public var settingItem: SettingItemModel

  init(settingItem: SettingItemModel) {
    self.settingItem = settingItem

    super.init(style: .default, reuseIdentifier: Self.identifier)
  }

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.settingItem = SettingItemModel()

    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  override public func updateConfiguration(using state: UICellConfigurationState) {
    contentView.subviews.forEach { $0.removeFromSuperview() }
    contentView.addSubview(ButtonView(settingItem: settingItem))
  }
}
