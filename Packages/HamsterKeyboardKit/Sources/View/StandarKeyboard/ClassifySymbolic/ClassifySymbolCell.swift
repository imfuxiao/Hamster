//
//  ClassifySymbolCell.swift
//
//
//  Created by morse on 2023/9/6.
//

import UIKit

class ClassifySymbolCell: UICollectionViewCell {
  override func updateConfiguration(using state: UICellConfigurationState) {
    if state.isSelected || state.isHighlighted {
      contentView.backgroundColor = .standardKeyboardBackground
    } else {
      contentView.backgroundColor = .clear
    }
  }
}
