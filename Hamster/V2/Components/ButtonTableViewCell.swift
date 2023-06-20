//
//  ButtonTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import UIKit

class ButtonTableViewCell: UITableViewCell, UIContextMenuInteractionDelegate {
  static let identifier = "ButtonTableCell"

  init(
    text: String,
    textTintColor: UIColor? = nil,
    favoriteButton: FavoriteButton? = nil,
    favoriteButtonHandler: (() -> Void)? = nil,
    buttonAction: @escaping () -> Void
  ) {
    self.text = text
    self.textTintColor = textTintColor
    self.buttonAction = buttonAction
    self.favoriteButton = favoriteButton
    self.favoriteButtonHandler = favoriteButtonHandler
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

    let interaction = UIContextMenuInteraction(delegate: self)
    addInteraction(interaction)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var text = ""
  var textTintColor: UIColor?
  var buttonAction: () -> Void = {}
  var favoriteButton: FavoriteButton?
  var favoriteButtonHandler: (() -> Void)?

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

// MARK: implementation UIContextMenuInteractionDelegate

extension ButtonTableViewCell {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    guard let favoriteButton = favoriteButton else { return nil }
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
          self.favoriteButtonHandler?()
        }
        return UIMenu(title: "", children: [favorites])
      }
    )
  }
}

enum FavoriteButton: String {
  case rimeDeploy
  case rimeSync
  case rimeRest
  case appBackup
}

extension UserDefaults {
  private static let favoriteButtonKey = "dev.fuxiao.apps.Hamster.favoriteButton"

  func getFavoriteButtons() -> [FavoriteButton] {
    let favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    return favoritesButtons.map { FavoriteButton(rawValue: $0)! }
  }

  func setFavoriteButton(button: FavoriteButton) {
    var favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    guard !favoritesButtons.contains(button.rawValue) else { return }
    favoritesButtons.append(button.rawValue)
    setValue(favoritesButtons, forKey: Self.favoriteButtonKey)
  }

  // true: 存在  false: 不存在
  func favoriteButtonExist(button: FavoriteButton) -> Bool {
    let favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    return favoritesButtons.contains(button.rawValue)
  }

  func removeFavoriteButton(button: FavoriteButton) {
    var favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    if let (index, _) = favoritesButtons.enumerated().first(where: { $1 == button.rawValue }) {
      favoritesButtons.remove(at: index)
      setValue(favoritesButtons, forKey: Self.favoriteButtonKey)
    }
  }
}
