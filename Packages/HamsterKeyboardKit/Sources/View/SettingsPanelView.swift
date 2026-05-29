//
//  SettingsPanelView.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import HamsterUIKit
import UIKit

/// 设置面板视图
class SettingsPanelView: NibLessView {
  private let style: CandidateBarStyle

  lazy var scrollView: UIScrollView = {
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    return scroll
  }()

  lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var stackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 20
    return stack
  }()

  // 钢琴音开关
  lazy var pianoSwitchLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "钢琴音"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var pianoSwitch: UISwitch = {
    let switchControl = UISwitch()
    switchControl.translatesAutoresizingMaskIntoConstraints = false
    return switchControl
  }()

  lazy var pianoSwitchContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  // 音量
  lazy var volumeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "音量"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var volumeSlider: UISlider = {
    let slider = UISlider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.minimumValue = 0
    slider.maximumValue = 1
    slider.value = 0.5
    return slider
  }()

  lazy var volumeValueLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "50%"
    label.font = .systemFont(ofSize: 14)
    label.textColor = .secondaryLabel
    return label
  }()

  lazy var volumeContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  // Mood 选择
  lazy var moodLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "风格"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var moodSegmentedControl: UISegmentedControl = {
    let items = ["默认", "欢快", "舒缓", "紧张"]
    let control = UISegmentedControl(items: items)
    control.translatesAutoresizingMaskIntoConstraints = false
    control.selectedSegmentIndex = 0
    return control
  }()

  lazy var moodContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init(style: CandidateBarStyle) {
    self.style = style
    super.init(frame: .zero)
    setupSubview()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubview() {
    backgroundColor = style.toolbarButtonBackgroundColor

    // 钢琴音开关容器
    pianoSwitchContainer.addSubview(pianoSwitchLabel)
    pianoSwitchContainer.addSubview(pianoSwitch)
    NSLayoutConstraint.activate([
      pianoSwitchLabel.leadingAnchor.constraint(equalTo: pianoSwitchContainer.leadingAnchor),
      pianoSwitchLabel.centerYAnchor.constraint(equalTo: pianoSwitchContainer.centerYAnchor),
      pianoSwitch.trailingAnchor.constraint(equalTo: pianoSwitchContainer.trailingAnchor),
      pianoSwitch.centerYAnchor.constraint(equalTo: pianoSwitchContainer.centerYAnchor),
      pianoSwitchContainer.heightAnchor.constraint(equalToConstant: 44),
    ])

    // 音量容器
    volumeContainer.addSubview(volumeLabel)
    volumeContainer.addSubview(volumeSlider)
    volumeContainer.addSubview(volumeValueLabel)
    NSLayoutConstraint.activate([
      volumeLabel.leadingAnchor.constraint(equalTo: volumeContainer.leadingAnchor),
      volumeLabel.topAnchor.constraint(equalTo: volumeContainer.topAnchor),
      volumeSlider.leadingAnchor.constraint(equalTo: volumeContainer.leadingAnchor),
      volumeSlider.trailingAnchor.constraint(equalTo: volumeValueLabel.leadingAnchor, constant: -8),
      volumeSlider.topAnchor.constraint(equalTo: volumeLabel.bottomAnchor, constant: 8),
      volumeValueLabel.trailingAnchor.constraint(equalTo: volumeContainer.trailingAnchor),
      volumeValueLabel.centerYAnchor.constraint(equalTo: volumeSlider.centerYAnchor),
      volumeValueLabel.widthAnchor.constraint(equalToConstant: 40),
      volumeContainer.heightAnchor.constraint(equalToConstant: 60),
    ])

    // Mood 容器
    moodContainer.addSubview(moodLabel)
    moodContainer.addSubview(moodSegmentedControl)
    NSLayoutConstraint.activate([
      moodLabel.leadingAnchor.constraint(equalTo: moodContainer.leadingAnchor),
      moodLabel.topAnchor.constraint(equalTo: moodContainer.topAnchor),
      moodSegmentedControl.leadingAnchor.constraint(equalTo: moodContainer.leadingAnchor),
      moodSegmentedControl.trailingAnchor.constraint(equalTo: moodContainer.trailingAnchor),
      moodSegmentedControl.topAnchor.constraint(equalTo: moodLabel.bottomAnchor, constant: 8),
      moodContainer.heightAnchor.constraint(equalToConstant: 60),
    ])

    // 添加到 stackView
    stackView.addArrangedSubview(pianoSwitchContainer)
    stackView.addArrangedSubview(volumeContainer)
    stackView.addArrangedSubview(moodContainer)

    contentView.addSubview(stackView)
    scrollView.addSubview(contentView)
    addSubview(scrollView)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
    ])

    // 音量滑块事件
    volumeSlider.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)
  }

  @objc func volumeChanged() {
    let value = Int(volumeSlider.value * 100)
    volumeValueLabel.text = "\(value)%"
  }
}
