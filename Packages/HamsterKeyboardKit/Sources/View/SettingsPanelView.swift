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

  /// AI 设置保存回调
  var onAISettingsSave: (([String: String]) -> Void)?

  /// GIF 设置保存回调
  var onGifSettingsSave: (([String: String]) -> Void)?

  /// 钢琴音设置保存回调
  var onPianoSettingsSave: (([String: Any]) -> Void)?

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

  // 主卡片视图
  lazy var cardsStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.spacing = 16
    return stack
  }()

  // AI 模型设置卡片
  lazy var aiCard: SettingsCardView = {
    let card = SettingsCardView(iconName: "brain", title: "AI 模型设置")
    card.translatesAutoresizingMaskIntoConstraints = false
    card.isUserInteractionEnabled = true
    return card
  }()

  // GIF 图源设置卡片
  lazy var gifCard: SettingsCardView = {
    let card = SettingsCardView(iconName: "photo.on.rectangle", title: "GIF 图源设置")
    card.translatesAutoresizingMaskIntoConstraints = false
    card.isUserInteractionEnabled = true
    return card
  }()

  // 钢琴音设置卡片
  lazy var pianoCard: SettingsCardView = {
    let card = SettingsCardView(iconName: "pianokeys", title: "钢琴音设置")
    card.translatesAutoresizingMaskIntoConstraints = false
    card.isUserInteractionEnabled = true
    return card
  }()

  // 子设置面板容器
  lazy var subSettingsContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  // AI 模型设置子面板
  lazy var aiSettingsPanel: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  // AI 设置内容
  lazy var aiSettingsStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 16
    return stack
  }()

  lazy var apiUrlLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "请求 URL"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var apiUrlTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.borderStyle = .roundedRect
    textField.placeholder = "https://api.example.com"
    return textField
  }()

  lazy var apiKeyLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "API Key"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var apiKeyTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.borderStyle = .roundedRect
    textField.placeholder = "输入 API Key"
    textField.isSecureTextEntry = true
    return textField
  }()

  lazy var modelIdLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "模型 ID"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var modelIdTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.borderStyle = .roundedRect
    textField.placeholder = "gpt-4"
    return textField
  }()

  lazy var systemPromptLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "系统提示词"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var systemPromptTextView: UITextView = {
    let textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.font = .systemFont(ofSize: 14)
    textView.layer.borderColor = UIColor.separator.cgColor
    textView.layer.borderWidth = 1
    textView.layer.cornerRadius = 8
    textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    return textView
  }()

  // GIF 图源设置子面板
  lazy var gifSettingsPanel: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  // GIF 设置内容
  lazy var gifSettingsStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 16
    return stack
  }()

  lazy var gifUrlLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "请求 URL"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var gifUrlTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.borderStyle = .roundedRect
    textField.placeholder = "https://api.gif.com"
    return textField
  }()

  lazy var gifApiKeyLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "API Key"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var gifApiKeyTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.borderStyle = .roundedRect
    textField.placeholder = "输入 GIF API Key"
    textField.isSecureTextEntry = true
    return textField
  }()

  // 钢琴音设置子面板
  lazy var pianoSettingsPanel: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  // 返回按钮
  lazy var backButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("←", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 24)
    return button
  }()

  // 子面板标题
  lazy var subPanelTitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 18, weight: .semibold)
    label.textColor = .label
    return label
  }()

  // 钢琴音设置内容
  lazy var pianoSettingsStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 20
    return stack
  }()

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

    // 主卡片视图
    cardsStackView.addArrangedSubview(aiCard)
    cardsStackView.addArrangedSubview(gifCard)
    cardsStackView.addArrangedSubview(pianoCard)

    contentView.addSubview(cardsStackView)
    contentView.addSubview(subSettingsContainer)
    scrollView.addSubview(contentView)
    addSubview(scrollView)

    // 子设置面板
    subSettingsContainer.addSubview(backButton)
    subSettingsContainer.addSubview(subPanelTitleLabel)
    subSettingsContainer.addSubview(aiSettingsPanel)
    subSettingsContainer.addSubview(gifSettingsPanel)
    subSettingsContainer.addSubview(pianoSettingsPanel)

    // AI 设置内容
    aiSettingsStackView.addArrangedSubview(apiUrlLabel)
    aiSettingsStackView.addArrangedSubview(apiUrlTextField)
    aiSettingsStackView.addArrangedSubview(apiKeyLabel)
    aiSettingsStackView.addArrangedSubview(apiKeyTextField)
    aiSettingsStackView.addArrangedSubview(modelIdLabel)
    aiSettingsStackView.addArrangedSubview(modelIdTextField)
    aiSettingsStackView.addArrangedSubview(systemPromptLabel)
    aiSettingsStackView.addArrangedSubview(systemPromptTextView)
    aiSettingsPanel.addSubview(aiSettingsStackView)

    // GIF 设置内容
    gifSettingsStackView.addArrangedSubview(gifUrlLabel)
    gifSettingsStackView.addArrangedSubview(gifUrlTextField)
    gifSettingsStackView.addArrangedSubview(gifApiKeyLabel)
    gifSettingsStackView.addArrangedSubview(gifApiKeyTextField)
    gifSettingsPanel.addSubview(gifSettingsStackView)

    // 钢琴音设置内容
    pianoSwitchContainer.addSubview(pianoSwitchLabel)
    pianoSwitchContainer.addSubview(pianoSwitch)
    pianoSettingsStackView.addArrangedSubview(pianoSwitchContainer)
    pianoSettingsStackView.addArrangedSubview(volumeContainer)
    pianoSettingsStackView.addArrangedSubview(moodContainer)
    pianoSettingsPanel.addSubview(pianoSettingsStackView)

    // 约束
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

      cardsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      cardsStackView.heightAnchor.constraint(equalToConstant: 120),

      subSettingsContainer.topAnchor.constraint(equalTo: cardsStackView.bottomAnchor, constant: 20),
      subSettingsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
      subSettingsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      subSettingsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

      backButton.leadingAnchor.constraint(equalTo: subSettingsContainer.leadingAnchor),
      backButton.topAnchor.constraint(equalTo: subSettingsContainer.topAnchor),
      backButton.heightAnchor.constraint(equalToConstant: 44),

      subPanelTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
      subPanelTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

      aiSettingsPanel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
      aiSettingsPanel.leadingAnchor.constraint(equalTo: subSettingsContainer.leadingAnchor),
      aiSettingsPanel.trailingAnchor.constraint(equalTo: subSettingsContainer.trailingAnchor),
      aiSettingsPanel.bottomAnchor.constraint(equalTo: subSettingsContainer.bottomAnchor),

      aiSettingsStackView.topAnchor.constraint(equalTo: aiSettingsPanel.topAnchor, constant: 16),
      aiSettingsStackView.leadingAnchor.constraint(equalTo: aiSettingsPanel.leadingAnchor, constant: 16),
      aiSettingsStackView.trailingAnchor.constraint(equalTo: aiSettingsPanel.trailingAnchor, constant: -16),
      aiSettingsStackView.bottomAnchor.constraint(equalTo: aiSettingsPanel.bottomAnchor, constant: -16),

      apiUrlTextField.heightAnchor.constraint(equalToConstant: 44),
      apiKeyTextField.heightAnchor.constraint(equalToConstant: 44),
      modelIdTextField.heightAnchor.constraint(equalToConstant: 44),
      systemPromptTextView.heightAnchor.constraint(equalToConstant: 120),

      gifSettingsPanel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
      gifSettingsPanel.leadingAnchor.constraint(equalTo: subSettingsContainer.leadingAnchor),
      gifSettingsPanel.trailingAnchor.constraint(equalTo: subSettingsContainer.trailingAnchor),
      gifSettingsPanel.bottomAnchor.constraint(equalTo: subSettingsContainer.bottomAnchor),

      gifSettingsStackView.topAnchor.constraint(equalTo: gifSettingsPanel.topAnchor, constant: 16),
      gifSettingsStackView.leadingAnchor.constraint(equalTo: gifSettingsPanel.leadingAnchor, constant: 16),
      gifSettingsStackView.trailingAnchor.constraint(equalTo: gifSettingsPanel.trailingAnchor, constant: -16),
      gifSettingsStackView.bottomAnchor.constraint(equalTo: gifSettingsPanel.bottomAnchor, constant: -16),

      gifUrlTextField.heightAnchor.constraint(equalToConstant: 44),
      gifApiKeyTextField.heightAnchor.constraint(equalToConstant: 44),

      pianoSettingsPanel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
      pianoSettingsPanel.leadingAnchor.constraint(equalTo: subSettingsContainer.leadingAnchor),
      pianoSettingsPanel.trailingAnchor.constraint(equalTo: subSettingsContainer.trailingAnchor),
      pianoSettingsPanel.bottomAnchor.constraint(equalTo: subSettingsContainer.bottomAnchor),

      pianoSettingsStackView.topAnchor.constraint(equalTo: pianoSettingsPanel.topAnchor, constant: 16),
      pianoSettingsStackView.leadingAnchor.constraint(equalTo: pianoSettingsPanel.leadingAnchor, constant: 16),
      pianoSettingsStackView.trailingAnchor.constraint(equalTo: pianoSettingsPanel.trailingAnchor, constant: -16),
      pianoSettingsStackView.bottomAnchor.constraint(equalTo: pianoSettingsPanel.bottomAnchor, constant: -16),
    ])

    // 钢琴音设置约束
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

    // 卡片点击事件
    let aiTap = UITapGestureRecognizer(target: self, action: #selector(handleAiCardTap))
    aiCard.addGestureRecognizer(aiTap)

    let gifTap = UITapGestureRecognizer(target: self, action: #selector(handleGifCardTap))
    gifCard.addGestureRecognizer(gifTap)

    let pianoTap = UITapGestureRecognizer(target: self, action: #selector(handlePianoCardTap))
    pianoCard.addGestureRecognizer(pianoTap)

    // 返回按钮事件
    backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)

    // 音量滑块事件
    volumeSlider.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)

    // 钢琴音开关事件
    pianoSwitch.addTarget(self, action: #selector(pianoSwitchChanged), for: .valueChanged)

    // Mood 切换事件
    moodSegmentedControl.addTarget(self, action: #selector(moodChanged), for: .valueChanged)
  }

  @objc func handleAiCardTap() {
    loadAISettings()
    showSubPanel(panel: aiSettingsPanel, title: "AI 模型设置")
  }

  @objc func handleGifCardTap() {
    loadGifSettings()
    showSubPanel(panel: gifSettingsPanel, title: "GIF 图源设置")
  }

  @objc func handlePianoCardTap() {
    loadPianoSettings()
    showSubPanel(panel: pianoSettingsPanel, title: "钢琴音设置")
  }

  @objc func handleBackTap() {
    // 返回时保存当前设置
    if !aiSettingsPanel.isHidden {
      saveAISettings()
    } else if !gifSettingsPanel.isHidden {
      saveGifSettings()
    } else if !pianoSettingsPanel.isHidden {
      savePianoSettings()
    }
    hideSubPanel()
  }

  func showSubPanel(panel: UIView, title: String) {
    cardsStackView.isHidden = true
    subSettingsContainer.isHidden = false
    subPanelTitleLabel.text = title

    aiSettingsPanel.isHidden = true
    gifSettingsPanel.isHidden = true
    pianoSettingsPanel.isHidden = true

    panel.isHidden = false
  }

  func hideSubPanel() {
    cardsStackView.isHidden = false
    subSettingsContainer.isHidden = true

    aiSettingsPanel.isHidden = true
    gifSettingsPanel.isHidden = true
    pianoSettingsPanel.isHidden = true
  }

  @objc func volumeChanged() {
    let value = Int(volumeSlider.value * 100)
    volumeValueLabel.text = "\(value)%"
    savePianoSettings()
  }

  @objc func pianoSwitchChanged() {
    savePianoSettings()
  }

  @objc func moodChanged() {
    savePianoSettings()
  }

  func saveAISettings() {
    let settings: [String: String] = [
      "apiUrl": apiUrlTextField.text ?? "",
      "apiKey": apiKeyTextField.text ?? "",
      "modelId": modelIdTextField.text ?? "",
      "systemPrompt": systemPromptTextView.text ?? ""
    ]
    onAISettingsSave?(settings)
  }

  func saveGifSettings() {
    let settings: [String: String] = [
      "gifUrl": gifUrlTextField.text ?? "",
      "gifApiKey": gifApiKeyTextField.text ?? ""
    ]
    onGifSettingsSave?(settings)
  }

  func savePianoSettings() {
    let settings: [String: Any] = [
      "pianoEnabled": pianoSwitch.isOn,
      "volume": volumeSlider.value,
      "mood": moodSegmentedControl.selectedSegmentIndex
    ]
    onPianoSettingsSave?(settings)
  }

  func loadAISettings() {
    let settings = MusicKeyboardSettings.shared
    apiUrlTextField.text = settings.aiApiUrl
    apiKeyTextField.text = settings.aiApiKey
    modelIdTextField.text = settings.aiModelId
    systemPromptTextView.text = settings.aiSystemPrompt
  }

  func loadGifSettings() {
    let settings = MusicKeyboardSettings.shared
    gifUrlTextField.text = settings.gifApiUrl
    gifApiKeyTextField.text = settings.gifApiKey
  }

  func loadPianoSettings() {
    let settings = MusicKeyboardSettings.shared
    pianoSwitch.isOn = settings.isPianoEnabled
    volumeSlider.value = settings.pianoVolume
    moodSegmentedControl.selectedSegmentIndex = settings.pianoMood
    let value = Int(volumeSlider.value * 100)
    volumeValueLabel.text = "\(value)%"
  }
}
