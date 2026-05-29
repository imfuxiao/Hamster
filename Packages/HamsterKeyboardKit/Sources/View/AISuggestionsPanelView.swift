//
//  AISuggestionsPanelView.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import HamsterUIKit
import UIKit

/// AI 建议面板视图
class AISuggestionsPanelView: NibLessView {
  private let style: CandidateBarStyle

  /// 复制建议回调
  var onCopySuggestion: ((String) -> Void)?

  /// 发送建议回调
  var onSendSuggestion: ((String) -> Void)?

  /// 重新生成回调
  var onRegenerate: (() -> Void)?

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
    stack.spacing = 12
    return stack
  }()

  // 重新生成按钮
  lazy var regenerateButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("🔄 重新生成", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    button.backgroundColor = .systemGray6
    button.layer.cornerRadius = 8
    return button
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

    // 添加示例建议项
    addSuggestionItem(text: "好的，我明白了！这个想法很有趣，我们可以进一步讨论。")
    addSuggestionItem(text: "没问题！我觉得这个方向是对的，我们可以试试看。")
    addSuggestionItem(text: "确实如此！我同意你的看法，我们可以继续深入探讨。")

    stackView.addArrangedSubview(regenerateButton)

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

      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      regenerateButton.heightAnchor.constraint(equalToConstant: 44),
    ])
  }

  func addSuggestionItem(text: String) {
    let item = AISuggestionItemView(text: text)
    item.translatesAutoresizingMaskIntoConstraints = false
    item.onCopy = { [weak self] text in
      self?.onCopySuggestion?(text)
    }
    item.onSend = { [weak self] text in
      self?.onSendSuggestion?(text)
    }
    stackView.addArrangedSubview(item)
  }

  func clearSuggestions() {
    // 移除除了重新生成按钮之外的所有子视图
    let itemsToRemove = stackView.arrangedSubviews.filter { $0 != regenerateButton }
    itemsToRemove.forEach { stackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
  }

  func updateSuggestions(_ suggestions: [String]) {
    clearSuggestions()
    suggestions.forEach { addSuggestionItem(text: $0) }
  }
}

/// AI 建议单项视图
class AISuggestionItemView: NibLessView {
  private let suggestionText: String

  /// 复制回调
  var onCopy: ((String) -> Void)?

  /// 发送回调
  var onSend: ((String) -> Void)?

  lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemBackground
    view.layer.cornerRadius = 12
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.08
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
    view.layer.shadowRadius = 8
    return view
  }()

  lazy var textLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 15)
    label.textColor = .label
    label.numberOfLines = 0
    return label
  }()

  lazy var actionsStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.spacing = 8
    stack.distribution = .fill
    return stack
  }()

  lazy var copyButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("📋 复制", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    button.backgroundColor = .systemGray6
    button.layer.cornerRadius = 6
    return button
  }()

  lazy var sendButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("📤 发送", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 6
    return button
  }()

  init(text: String) {
    self.suggestionText = text
    super.init(frame: .zero)
    setupSubview()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubview() {
    textLabel.text = suggestionText

    containerView.addSubview(textLabel)
    containerView.addSubview(actionsStackView)
    actionsStackView.addArrangedSubview(copyButton)
    actionsStackView.addArrangedSubview(sendButton)

    addSubview(containerView)

    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

      textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
      textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
      textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

      actionsStackView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 12),
      actionsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
      actionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
      actionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
      actionsStackView.heightAnchor.constraint(equalToConstant: 36),

      copyButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
      sendButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
    ])

    // 添加按钮点击事件
    copyButton.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
  }

  @objc func handleCopy() {
    UIPasteboard.general.string = suggestionText
    onCopy?(suggestionText)
  }

  @objc func handleSend() {
    onSend?(suggestionText)
  }
}
