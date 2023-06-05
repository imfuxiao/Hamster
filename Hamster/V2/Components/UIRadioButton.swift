//
//  RadioButton.swift
//  Hamster
//
//  Created by morse on 2023/6/18.
//

import UIKit

class UIRadioButton: UIControl {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  var unselectedBackgroundColor: UIColor = .secondarySystemFill {
    didSet {
      contentView.backgroundColor = unselectedBackgroundColor
    }
  }

  var borderColor: UIColor = .secondarySystemBackground {
    didSet {
      contentView.layer.borderColor = (isOn ? selectedColor : borderColor).cgColor
    }
  }

  var selectedColor: UIColor = .systemGreen {
    didSet {
      checkedView.backgroundColor = selectedColor
      contentView.layer.borderColor = (isOn ? selectedColor : borderColor).cgColor
    }
  }

  var isOn: Bool = false {
    didSet {
      updateState()
    }
  }

  private let size: CGFloat = 24
  private let checkedViewSize: CGFloat = 12

  private let contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.borderWidth = 1.2
    return view
  }()

  private let checkedView: UIView = {
//    let view = UIView()
    let view = UIImageView(image: UIImage(systemName: "checkmark"))
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private func setup() {
    addSubview(contentView)
    contentView.addSubview(checkedView)

    contentView.layer.cornerRadius = size / 2
    checkedView.layer.cornerRadius = checkedViewSize / 2

    updateState()

    NSLayoutConstraint.activate([
      checkedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      checkedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      checkedView.widthAnchor.constraint(equalToConstant: checkedViewSize),
      checkedView.heightAnchor.constraint(equalToConstant: checkedViewSize),

      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
      contentView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
      contentView.widthAnchor.constraint(equalToConstant: size),
      contentView.heightAnchor.constraint(equalToConstant: size)
    ])
  }

  private func updateState() {
    contentView.backgroundColor = unselectedBackgroundColor
    checkedView.backgroundColor = selectedColor
    contentView.layer.borderColor = (isOn ? selectedColor : borderColor).cgColor
    checkedView.isHidden = !isOn
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    isOn.toggle()
    sendActions(for: .valueChanged)
  }
}
