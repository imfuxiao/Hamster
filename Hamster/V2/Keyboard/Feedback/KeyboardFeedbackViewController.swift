//
//  KeyboardFeedbackViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import UIKit

class KeyboardFeedbackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  init(appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let appSettings: HamsterAppSettings

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.allowsSelection = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  lazy var soundSettingView: UIView = {
    let stackView = newStackView
    let slider = newSlider

    stackView.addArrangedSubview(image(name: "speaker.wave.1"))
    stackView.addArrangedSubview(slider)
    stackView.addArrangedSubview(image(name: "speaker.wave.3"))

    return stackView
  }()

  lazy var hapticsSettingView: UIView = {
    let stackView = newStackView

    // UIImpactFeedbackGenerator.FeedbackStyle
    let slider = newSlider
    slider.minimumValue = 0
    slider.maximumValue = 1
    slider.isContinuous = false
    slider.value = Float(appSettings.keyboardFeedbackHapticIntensity)
    slider.addTarget(self, action: #selector(changeHaptic(_:)), for: .valueChanged)

    let leftImage = image(name: "iphone.radiowaves.left.and.right")
    leftImage.tintColor = .secondaryLabel
    stackView.addArrangedSubview(leftImage)
    stackView.addArrangedSubview(slider)
    stackView.addArrangedSubview(image(name: "iphone.radiowaves.left.and.right"))

    return stackView
  }()
}

// MARK: custom method

extension KeyboardFeedbackViewController {
  var newStackView: UIStackView {
    let stackView = UIStackView(frame: .zero)

    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 8

    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }

  var newSlider: UISlider {
    let slider = UISlider(frame: .zero)
    return slider
  }

  func image(name: String) -> UIImageView {
    let view = UIImageView(image: UIImage(systemName: name))
    view.contentMode = .scaleAspectFit
    return view
  }

  @objc func changeHaptic(_ sender: UISlider) {
//    let roundedValue = Int(sender.value)
//    sender.value = Float(roundedValue)
    Logger.shared.log.debug("change haptic: \(sender.value)")
//    let style = UIImpactFeedbackGenerator.FeedbackStyle(rawValue: roundedValue) ?? .medium
    UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: CGFloat(sender.value))
    // TODO: 改为float类型
    appSettings.keyboardFeedbackHapticIntensity = Int(sender.value)
  }
}

// MARK: override UIViewController

extension KeyboardFeedbackViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension KeyboardFeedbackViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return ToggleTableViewCell(text: "开启按键声", toggleValue: appSettings.enableKeyboardFeedbackSound) { [unowned self] in
        appSettings.enableKeyboardFeedbackSound = $0
      }
    }

    if indexPath.section == 1 {
      return ToggleCustomTableViewCell(text: "按键震动", tableView: self.tableView, customView: hapticsSettingView, toggleValue: appSettings.enableKeyboardFeedbackHaptic, toggleHandled: { [unowned self] in
        appSettings.enableKeyboardFeedbackHaptic = $0
      })
    }

    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}
