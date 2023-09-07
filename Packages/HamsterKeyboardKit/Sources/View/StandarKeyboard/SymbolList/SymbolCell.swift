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
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    if state.isHighlighted || state.isSelected {
      contentView.backgroundColor = .white
    } else {
      contentView.backgroundColor = .standardDarkButtonBackground
    }

    separatorLayoutGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
  }
}
