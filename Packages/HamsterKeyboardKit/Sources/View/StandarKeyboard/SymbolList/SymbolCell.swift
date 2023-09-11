//
//  SymbolCell.swift
//
//
//  Created by morse on 2023/9/7.
//

import UIKit

/// 符号单元格
class SymbolCell: UICollectionViewListCell {
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)

    self.textLabel.text = ""
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public lazy var textLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0),
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])
    return label
  }()

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    if state.isHighlighted || state.isSelected {
      contentView.backgroundColor = .secondarySystemBackground
    } else {
      contentView.backgroundColor = .standardDarkButtonBackground
    }

    separatorLayoutGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
  }
}
