//
//  ButtonTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import HamsterKit
import HamsterUIKit
import OSLog
import ProgressHUD
import UIKit

public class ButtonTableViewCell: NibLessTableViewCell {
  static let identifier = "ButtonTableCell"

  // MARK: - properties

  override public var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.settingItemModel = self.settingItem
    return state
  }

  lazy var buttonView: UIButton = {
    let button = UIButton(type: .roundedRect)
    let interaction = UIContextMenuInteraction(delegate: self)
    button.addInteraction(interaction)
    return button
  }()

  private var settingItem: SettingItemModel

  // MARK: - initialization

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.settingItem = SettingItemModel()

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupButtonView()
  }

  // MARK: - methods

  override public func prepareForReuse() {
    super.prepareForReuse()

    buttonView.titleLabel?.tintColor = nil
  }

  func updateWithSettingItem(_ item: SettingItemModel) {
    guard settingItem != item else { return }
    self.settingItem = item
    setNeedsUpdateConfiguration()
  }

  override public func updateConfiguration(using state: UICellConfigurationState) {
    buttonView.setTitle(state.settingItemModel?.text, for: .normal)
    buttonView.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    if let textTintColor = state.settingItemModel?.textTintColor {
      buttonView.titleLabel?.tintColor = textTintColor
    }
    buttonView.addTarget(self, action: #selector(buttonHandled), for: .touchUpInside)
  }

  func setupButtonView() {
    contentView.addSubview(buttonView)
    buttonView.fillSuperview()
//    buttonView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      buttonView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
//      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonView.bottomAnchor, multiplier: 1.0),
//      buttonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//      buttonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//    ])
  }

  @objc func buttonHandled() {
    Task {
      do {
        try await settingItem.buttonAction?()
      } catch {
        Logger.statistics.error("\(#file) error: \(error)")
        ProgressHUD.failed("操作异常：\(error.localizedDescription)", delay: 1.5)
      }
    }
  }
}

extension ButtonTableViewCell: UIContextMenuInteractionDelegate {
  public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    guard settingItem.type == .button else { return nil }
    guard let favoriteButton = settingItem.favoriteButton else { return nil }
    let isExists = UserDefaults.standard.favoriteButtonExist(button: favoriteButton)
    return UIContextMenuConfiguration(actionProvider: { [unowned self] _ in
      UIMenu(title: "", children: [isExists ? removeFavoriteAction(favoriteButton) : addFavoriteAction(favoriteButton)])
    })
  }

  func addFavoriteAction(_ favoriteButton: FavoriteButton) -> UIAction {
    return UIAction(
      title: "添加至首页",
      image: UIImage(systemName: "star.fill")?.withTintColor(.systemYellow),
      handler: { _ in
        UserDefaults.standard.setFavoriteButton(button: favoriteButton)
      })
  }

  func removeFavoriteAction(_ favoriteButton: FavoriteButton) -> UIAction {
    return UIAction(
      title: "取消添加",
      image: UIImage(systemName: "star.slash.fill")?.withTintColor(.systemYellow),
      handler: { _ in
        UserDefaults.standard.removeFavoriteButton(button: favoriteButton)
      })
  }
}
