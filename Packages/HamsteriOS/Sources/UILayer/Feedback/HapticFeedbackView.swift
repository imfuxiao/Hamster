//
//  HapticFeedbackView.swift
//
//
//  Created by morse on 14/7/2023.
//

import Combine
import HamsterUIKit
import UIKit

class HapticFeedbackView: NibLessView {
  // MARK: properties

  private let keyboardFeedbackViewModel: KeyboardFeedbackViewModel

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "按键震动"
    return label
  }()

  lazy var switchView: UISwitch = {
    let switchView = UISwitch(frame: .zero)
    switchView.isOn = keyboardFeedbackViewModel.enableHapticFeedback
    switchView.addTarget(
      keyboardFeedbackViewModel,
      action: #selector(keyboardFeedbackViewModel.toggleAction),
      for: .valueChanged
    )
    return switchView
  }()

  private lazy var firstRowView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [label, switchView])

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 8

    return stackView
  }()

  /// 反馈强度滑动
  private lazy var hapticFeedbackIntensitySlideView: UISlider = {
    let slider = UISlider(frame: .zero)
    slider.minimumValue = Float(keyboardFeedbackViewModel.minimumHapticFeedbackIntensity)
    slider.maximumValue = Float(keyboardFeedbackViewModel.maximumHapticFeedbackIntensity)
    slider.isContinuous = false
    slider.value = Float(keyboardFeedbackViewModel.hapticFeedbackIntensity)
    slider.addTarget(
      keyboardFeedbackViewModel,
      action: #selector(keyboardFeedbackViewModel.changeHaptic(_:)),
      for: .valueChanged
    )
    return slider
  }()

  private lazy var secondaryRowView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    let leftImage = image(name: "iphone.radiowaves.left.and.right")
    leftImage.tintColor = .secondaryLabel

    stackView.addArrangedSubview(leftImage)
    stackView.addArrangedSubview(hapticFeedbackIntensitySlideView)
    stackView.addArrangedSubview(image(name: "iphone.radiowaves.left.and.right"))

    return stackView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardFeedbackViewModel: KeyboardFeedbackViewModel) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModel

    super.init(frame: frame)

    constructViewHierarchy()
    activateViewConstraints()
  }

  override func constructViewHierarchy() {
    addSubview(firstRowView)
    if keyboardFeedbackViewModel.enableHapticFeedback {
      addSubview(secondaryRowView)
    }
  }

  override func activateViewConstraints() {
    firstRowView.translatesAutoresizingMaskIntoConstraints = false

    if keyboardFeedbackViewModel.enableHapticFeedback {
      secondaryRowView.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([
        firstRowView.topAnchor.constraint(equalTo: topAnchor),
        firstRowView.leadingAnchor.constraint(equalTo: leadingAnchor),
        firstRowView.trailingAnchor.constraint(equalTo: trailingAnchor),

        secondaryRowView.topAnchor.constraint(equalTo: firstRowView.bottomAnchor, constant: 8),
        secondaryRowView.bottomAnchor.constraint(equalTo: bottomAnchor),
        secondaryRowView.leadingAnchor.constraint(equalTo: leadingAnchor),
        secondaryRowView.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
    } else {
      NSLayoutConstraint.activate([
        firstRowView.topAnchor.constraint(equalTo: topAnchor),
        firstRowView.bottomAnchor.constraint(equalTo: bottomAnchor),
        firstRowView.leadingAnchor.constraint(equalTo: leadingAnchor),
        firstRowView.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
    }
  }
}

// MARK: customs

extension HapticFeedbackView {
  private func image(name: String) -> UIImageView {
    let view = UIImageView(image: UIImage(systemName: name))
    view.contentMode = .scaleAspectFit
    return view
  }
}
