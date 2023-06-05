//
//  TextFieldTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
  static let identifier = "TextFieldTableViewCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.iconName = nil
    self.placeholder = nil
    self.text = ""
    self.textHandled = { _ in }
    self.shouldBeginEditing = { _ in true }
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addTextField()
  }

  init(
    iconName: String? = nil,
    placeholder: String? = nil,
    text: String = "",
    textHandled: @escaping (String) -> Void,
    shouldBeginEditing: @escaping ((UITextField) -> Bool) = { _ in true }
  ) {
    self.iconName = iconName
    self.placeholder = placeholder
    self.text = text
    self.textHandled = textHandled
    self.shouldBeginEditing = shouldBeginEditing
    super.init(style: .default, reuseIdentifier: Self.identifier)
    addTextField()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let iconName: String?
  let placeholder: String?
  let text: String
  var textHandled: (String) -> Void
  var shouldBeginEditing: (UITextField) -> Bool

  lazy var iconView: UIView = {
    let iconContainerView = UIView(frame: .zero)
    guard let image = UIImage(systemName: iconName ?? "") else { return iconContainerView }
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit

    imageView.translatesAutoresizingMaskIntoConstraints = false
    iconContainerView.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
      imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: iconContainerView.leadingAnchor, multiplier: 1.0),
      iconContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0),
    ])

    return iconContainerView
  }()

  lazy var textField: UITextField = {
    let textField = CellTextField(frame: .zero)
    textField.text = text
    textField.leftViewMode = .always
    textField.rightViewMode = .always
    textField.clearButtonMode = .whileEditing
    textField.placeholder = placeholder
    return textField
  }()

  @objc func textFieldFocus() {
    textField.becomeFirstResponder()
  }

  func addTextField() {
    let textField = textField
    textField.delegate = self
    if iconName != nil {
      let iconView = iconView
      iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldFocus)))
      textField.leftView = iconView
    }
    textField.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(textField)

    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
    ])
  }
}

// MARK: implementation UITextFieldDelegate

extension TextFieldTableViewCell {
  func textFieldDidEndEditing(_ textField: UITextField) {
    textHandled(textField.text ?? "")
  }

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    shouldBeginEditing(textField)
  }
}

class CellTextField: UITextField {
  // 调整清除按钮位置
  override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    let originalRect = super.clearButtonRect(forBounds: bounds)
    return CGRectOffset(originalRect, -8, 0)
  }
}
