//
//  ClassifySymbolCell.swift
//
//
//  Created by morse on 2023/9/6.
//

import UIKit

class ClassifySymbolCell: UICollectionViewListCell {
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var highlightedColor: UIColor? = nil
  public var normalColor: UIColor? = nil
  public lazy var textLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: contentView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor),
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      separatorLayoutGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
    ])
    return label
  }()

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
    if state.isHighlighted || state.isSelected {
      backgroundConfig.backgroundColor = highlightedColor
    } else {
      backgroundConfig.backgroundColor = normalColor
    }
    self.backgroundConfiguration = backgroundConfig
  }
}
