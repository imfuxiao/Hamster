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
}

private class TextFieldView: NibLessView, UITextFieldDelegate {
  // MARK: properties

  private let settingItem: SettingItemModel

  lazy var iconView: UIView? = {
    guard let iconImage = settingItem.icon else { return nil }

    let imageView = UIImageView(image: iconImage)
    imageView.contentMode = .scaleAspectFit

    return imageView
  }()

  lazy var textField: UITextField = {
    let textField = CellTextField(frame: .zero)
    textField.text = settingItem.text
    textField.leftViewMode = .always
    textField.rightViewMode = .always
    textField.clearButtonMode = .whileEditing
    textField.placeholder = settingItem.placeholder
    return textField
  }()

  // MARK: methods

  init(frame: CGRect = .zero, settingItem: SettingItemModel) {
    self.settingItem = settingItem
    super.init(frame: frame)
  }

  @objc func textFieldFocus() {
    textField.becomeFirstResponder()
  }

  override func constructViewHierarchy() {
    if let iconView = iconView {
      iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldFocus)))
      textField.leftView = iconView
    }

    addSubview(textField)
    textField.delegate = self
  }

  override func activateViewConstraints() {
    textField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      textField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
    ])
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()
  }

  // MARK: implementation UITextFieldDelegate

  func textFieldDidEndEditing(_ textField: UITextField) {
    settingItem.textHandled?(textField.text ?? "")
  }

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    settingItem.shouldBeginEditing?(textField) ?? true
  }
}

class TextFieldTableViewCell: NibLessTableViewCell {
  static let identifier = "TextFieldTableViewCell"

  // MARK: properties

  public var settingItem: SettingItemModel

  // MARK: methods

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.settingItem = SettingItemModel()
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  init(settingItem: SettingItemModel) {
    self.settingItem = settingItem
    super.init(style: .default, reuseIdentifier: Self.identifier)
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    contentView.subviews.forEach { $0.removeFromSuperview() }
    contentView.addSubview(TextFieldView(settingItem: settingItem))
  }
}
