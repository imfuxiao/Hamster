//
//  KeyboardLayoutCell.swift
//
//
//  Created by morse on 2023/9/13.
//

import HamsterKeyboardKit
import UIKit

/// 键盘布局单元格
class KeyboardLayoutCell: UICollectionViewListCell {
  private var item: KeyboardSettingsViewModel.KeyboardLayoutItem?

  public var checked: Bool = false {
    didSet {
      checkbox.isSelected = checked
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
    label.isUserInteractionEnabled = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var settingView: UIView = {
    let view = SettingView()
    view.isUserInteractionEnabled = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
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
    contentView.addSubview(settingView)

    NSLayoutConstraint.activate([
      separatorLayoutGuide.leadingAnchor.constraint(equalTo: label.leadingAnchor),

      checkbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      checkbox.centerYAnchor.constraint(equalTo: label.centerYAnchor),

      label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor),
      label.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 2),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 2),

      settingView.heightAnchor.constraint(equalTo: settingView.widthAnchor),
      settingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      settingView.leadingAnchor.constraint(equalTo: label.trailingAnchor),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: settingView.trailingAnchor, multiplier: 2),
    ])

    let checkboxGesture = UITapGestureRecognizer()
    checkboxGesture.addTarget(self, action: #selector(selectKeyboard))
    checkbox.addGestureRecognizer(checkboxGesture)

    let labelGesture = UITapGestureRecognizer()
    labelGesture.addTarget(self, action: #selector(selectKeyboard))
    label.addGestureRecognizer(labelGesture)

    let settingGesture = UITapGestureRecognizer()
    settingGesture.addTarget(self, action: #selector(detailsSetting))
    settingView.addGestureRecognizer(settingGesture)
  }

  func updateWithSettingItem(_ item: KeyboardSettingsViewModel.KeyboardLayoutItem) {
    self.item = item
    label.text = item.keyboardType.label
    settingView.isHidden = item.keyboardType.isCustom
    checked = item.checkState
    setNeedsUpdateConfiguration()
  }

  @objc func selectKeyboard() {
    item?.setChecked()
  }

  @objc func detailsSetting() {
    item?.settings()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {}
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

private class SettingView: UIView {
  lazy var settingView: UIView = {
    let view = UIImageView(image: UIImage(systemName: "chevron.right"))
    view.contentMode = .scaleAspectFit
    view.tintColor = UIColor.secondaryLabel
    view.isUserInteractionEnabled = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init() {
    super.init(frame: .zero)

    self.isUserInteractionEnabled = true
    addSubview(settingView)
    settingView.fillSuperview()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
