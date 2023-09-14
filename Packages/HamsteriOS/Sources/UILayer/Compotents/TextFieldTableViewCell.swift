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

  // MARK: properties

  public var settingItem: SettingItemModel {
    didSet {
      if let iconImage = settingItem.icon {
        let imageView = UIImageView(image: iconImage)
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldFocus)))
        textField.leftView = imageView
      }

      textField.text = settingItem.textValue
      textField.placeholder = settingItem.placeholder
    }
  }

  let textField: UITextField = {
    let textField = CellTextField(frame: .zero)
    textField.leftViewMode = .always
    textField.rightViewMode = .always
    textField.clearButtonMode = .whileEditing
    return textField
  }()

  // MARK: methods

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.settingItem = SettingItemModel()

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupTextFieldView()
  }

  init(settingItem: SettingItemModel) {
    self.settingItem = settingItem

    super.init(style: .default, reuseIdentifier: Self.identifier)

    setupTextFieldView()
  }

  func setupTextFieldView() {
    contentView.addSubview(textField)
    textField.delegate = self
    textField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: textField.bottomAnchor, multiplier: 1),
      textField.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1),
    ])
  }

  @objc func textFieldFocus() {
    textField.becomeFirstResponder()
  }

  // MARK: implementation UITextFieldDelegate

  func textFieldDidEndEditing(_ textField: UITextField) {
    settingItem.textHandled?(textField.text ?? "")
  }

  // 当按下 "return" 键时调用。
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
