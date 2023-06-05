//
//  PullDownMenuCell.swift
//
//
//  Created by morse on 2023/10/18.
//

import HamsterUIKit
import UIKit

/// 下拉选择按钮
public class PullDownMenuCell: NibLessTableViewCell {
  static let identifier = "PullDownMenuCell"

  var settingItem: SettingItemModel?

  override public var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.settingItemModel = self.settingItem
    return state
  }

  lazy var titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()

  lazy var valueButton: UIButton = {
    let valueButton = UIButton(type: .custom)
    valueButton.setTitleColor(.secondaryLabel, for: .normal)
    valueButton.contentHorizontalAlignment = .trailing
    valueButton.translatesAutoresizingMaskIntoConstraints = false
    return valueButton
  }()

  lazy var iconImageView: UIImageView = {
    let view = UIImageView(image: UIImage(systemName: "chevron.down"))
    view.contentMode = .scaleAspectFit
    view.tintColor = UIColor.secondaryLabel
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupContentView()
  }

  func setupContentView() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(valueButton)
    contentView.addSubview(iconImageView)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
      titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),

      valueButton.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: valueButton.bottomAnchor, multiplier: 1),
      valueButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

      iconImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: valueButton.trailingAnchor, multiplier: 1),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: iconImageView.trailingAnchor, multiplier: 1),
      iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
    ])
  }

  func updateWithSettingItem(_ item: SettingItemModel) {
    guard settingItem != item else { return }
    self.settingItem = item
    setNeedsUpdateConfiguration()
  }

  override public func updateConfiguration(using state: UICellConfigurationState) {
    titleLabel.text = state.settingItemModel?.text
    valueButton.setTitle(state.settingItemModel?.textValue?(), for: .normal)
    if let actions = state.settingItemModel?.pullDownMenuActionsBuilder?() {
      valueButton.menu = UIMenu(title: "", children: actions)
      valueButton.showsMenuAsPrimaryAction = true
    }
  }

}
