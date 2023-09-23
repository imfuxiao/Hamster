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

  let buttonView: UIButton = {
    let button = UIButton(type: .roundedRect)
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
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      buttonView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonView.bottomAnchor, multiplier: 1.0),
      buttonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      buttonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])
  }

  @objc func buttonHandled() {
    do {
      try settingItem.buttonAction?()
    } catch {
      Logger.statistics.error("\(#file) error: \(error)")
      ProgressHUD.showError("操作异常：\(error.localizedDescription)", delay: 1.5)
    }
  }
}
