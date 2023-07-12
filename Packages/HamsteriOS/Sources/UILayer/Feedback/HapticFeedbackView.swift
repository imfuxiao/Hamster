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

  private var subscriptions = Set<AnyCancellable>()

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

  private lazy var firstView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    stackView.addArrangedSubview(label)
    stackView.addArrangedSubview(switchView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  private lazy var secondaryView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  lazy var hapticFeedbackIntensitySlideView: UISlider = {
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

  lazy var hapticsSettingView: UIView = {
    let stackView = UIStackView(frame: .zero)
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
  }

  override func constructViewHierarchy() {
    addSubview(firstView)
    addSubview(secondaryView)
  }

  override func activateViewConstraints() {
    NSLayoutConstraint.activate([
      firstView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      firstView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      firstView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

      secondaryView.topAnchor.constraint(equalToSystemSpacingBelow: firstView.bottomAnchor, multiplier: 1.0),
      secondaryView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      secondaryView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      secondaryView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
    ])
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()

    keyboardFeedbackViewModel.$enableHapticFeedback
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        if $0 {
          secondaryView.addArrangedSubview(hapticsSettingView)
        } else {
          hapticsSettingView.removeFromSuperview()
          secondaryView.removeArrangedSubview(hapticsSettingView)
        }
      }
      .store(in: &subscriptions)
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
