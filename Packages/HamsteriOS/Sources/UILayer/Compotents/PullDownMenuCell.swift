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
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return label
  }()

  lazy var valueButton: UIButton = {
    let valueButton = UIButton(type: .custom)
    valueButton.setTitleColor(.secondaryLabel, for: .normal)
    valueButton.contentHorizontalAlignment = .trailing
    valueButton.translatesAutoresizingMaskIntoConstraints = false
    valueButton.tintColor = .secondaryLabel

    valueButton.configuration = UIButton.Configuration.plain()
    valueButton.configuration?.image = UIImage(systemName: "chevron.down")
    valueButton.configuration?.imagePlacement = .trailing

    valueButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    return valueButton
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupContentView()
  }

  func setupContentView() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(valueButton)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
      titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),

      valueButton.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: valueButton.bottomAnchor, multiplier: 1),
      valueButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: valueButton.trailingAnchor, multiplier: 1),

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
