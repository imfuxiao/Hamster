//
//  TextFieldTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import HamsterUIKit
import UIKit

class CellTextField: UITextField {
  // 调整清除按钮位置
  override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    let originalRect = super.clearButtonRect(forBounds: bounds)
    return CGRectOffset(originalRect, -8, 0)
  }

  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    let originalRect = super.rightViewRect(forBounds: bounds)
    return CGRectOffset(originalRect, 8, 0)
  }

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    let originalRect = super.textRect(forBounds: bounds)
    return CGRectOffset(originalRect, 8, 0)
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    let originalRect = super.editingRect(forBounds: bounds)
    return CGRectOffset(originalRect, 8, 0)
  }
}

class TextFieldTableViewCell: NibLessTableViewCell, UITextFieldDelegate {
  static let identifier = "TextFieldTableViewCell"

  // MARK: - properties

  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.settingItemModel = self.settingItem
    return state
  }

  private var settingItem: SettingItemModel? = nil

  public lazy var textField: UITextField = {
    let textField = CellTextField(frame: .zero)
    textField.leftViewMode = .always
    textField.rightViewMode = .always
    textField.clearButtonMode = .whileEditing
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.textAlignment = .left
    textField.delegate = self
    textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return textField
  }()

  private lazy var leftTextLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return label
  }()

  // MARK: - Initialization

  override init(style: UITableViewCell.CellStyle = .default, reuseIdentifier: String? = TextFieldTableViewCell.identifier) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupTextFieldView()
  }

  // MARK: - methods

  override func updateConfiguration(using state: UICellConfigurationState) {
    if let iconImage = state.settingItemModel?.icon {
      let imageView = UIImageView(image: iconImage)
      imageView.contentMode = .scaleAspectFit
      imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldFocus)))
      textField.leftView = imageView
    }
    leftTextLabel.text = state.settingItemModel?.text
    textField.text = state.settingItemModel?.textValue?()
    textField.placeholder = state.settingItemModel?.placeholder
  }

  func updateWithSettingItem(_ item: SettingItemModel) {
    guard settingItem != item else { return }
    self.settingItem = item
    setNeedsUpdateConfiguration()
  }

  func setupTextFieldView() {
    contentView.addSubview(leftTextLabel)
    contentView.addSubview(textField)

    NSLayoutConstraint.activate([
      leftTextLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: leftTextLabel.bottomAnchor, multiplier: 1),

      leftTextLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),

      textField.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: textField.bottomAnchor, multiplier: 1),
      textField.leadingAnchor.constraint(equalToSystemSpacingAfter: leftTextLabel.trailingAnchor, multiplier: 2),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1),
    ])
  }

  @objc func textFieldFocus() {
    textField.becomeFirstResponder()
  }

  // MARK: implementation UITextFieldDelegate

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    settingItem?.textFieldShouldBeginEditing ?? true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    settingItem?.textHandled?(textField.text ?? "")
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return true
  }

  // 当按下 "return" 键时调用。
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
