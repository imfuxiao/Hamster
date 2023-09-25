//
//  KeyboardLayoutCell.swift
//
//
//  Created by morse on 2023/9/13.
//

import UIKit

/// 键盘布局单元格
class KeyboardLayoutCell: UICollectionViewListCell {
  override var isSelected: Bool {
    didSet {
      checkbox.isSelected = isSelected
    }
  }

  public var displayCheckbox: Bool = true {
    didSet {
      checkbox.isHidden = !displayCheckbox
    }
  }

  private lazy var checkbox: Checkbox = {
    let checkbox = Checkbox()
    checkbox.isUserInteractionEnabled = true
    checkbox.translatesAutoresizingMaskIntoConstraints = false
    return checkbox
  }()

  public lazy var label: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    accessories = []
  }

  func setupView() {
    contentView.addSubview(checkbox)
    contentView.addSubview(label)

    NSLayoutConstraint.activate([
      separatorLayoutGuide.leadingAnchor.constraint(equalTo: label.leadingAnchor),

      checkbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      checkbox.trailingAnchor.constraint(equalTo: label.leadingAnchor),
      checkbox.centerYAnchor.constraint(equalTo: label.centerYAnchor),

      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      label.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2.0),
      bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 2.0),
    ])
  }
}

private class Checkbox: UIView {
  public var isSelected: Bool = false {
    didSet {
      checkboxImageView.image = isSelected ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
      checkboxImageView.tintColor = isSelected ? .systemGreen : .systemGray
    }
  }

  private lazy var checkboxImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.image = UIImage(systemName: "circle")
    view.contentMode = .scaleAspectFit
    view.tintColor = .systemGray
    view.isUserInteractionEnabled = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init() {
    super.init(frame: .zero)

    addSubview(checkboxImageView)
    NSLayoutConstraint.activate([
      checkboxImageView.widthAnchor.constraint(equalTo: checkboxImageView.heightAnchor, multiplier: 1.0),

      checkboxImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1.0),
      trailingAnchor.constraint(equalToSystemSpacingAfter: checkboxImageView.trailingAnchor, multiplier: 1.0),
      checkboxImageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1.0),
      bottomAnchor.constraint(equalToSystemSpacingBelow: checkboxImageView.bottomAnchor, multiplier: 1.0),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
