//
//  TextPlaybackPanelView.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import HamsterUIKit
import UIKit

/// 文本回放面板视图
class TextPlaybackPanelView: NibLessView {
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
    stack.spacing = 16
    return stack
  }()

  // 文本输入框
  lazy var textView: UITextView = {
    let textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.font = .systemFont(ofSize: 16)
    textView.layer.borderColor = UIColor.separator.cgColor
    textView.layer.borderWidth = 1
    textView.layer.cornerRadius = 8
    textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    textView.placeholder = "粘贴文本到此处播放"
    return textView
  }()

  // 播放按钮
  lazy var playButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("播放", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 8
    return button
  }()

  // 多轨叠加开关
  lazy var multiTrackLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "多轨叠加"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  lazy var multiTrackSwitch: UISwitch = {
    let switchControl = UISwitch()
    switchControl.translatesAutoresizingMaskIntoConstraints = false
    return switchControl
  }()

  lazy var multiTrackContainer: UIView = {
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

    // 多轨叠加容器
    multiTrackContainer.addSubview(multiTrackLabel)
    multiTrackContainer.addSubview(multiTrackSwitch)
    NSLayoutConstraint.activate([
      multiTrackLabel.leadingAnchor.constraint(equalTo: multiTrackContainer.leadingAnchor),
      multiTrackLabel.centerYAnchor.constraint(equalTo: multiTrackContainer.centerYAnchor),
      multiTrackSwitch.trailingAnchor.constraint(equalTo: multiTrackContainer.trailingAnchor),
      multiTrackSwitch.centerYAnchor.constraint(equalTo: multiTrackContainer.centerYAnchor),
      multiTrackContainer.heightAnchor.constraint(equalToConstant: 44),
    ])

    // 添加到 stackView
    stackView.addArrangedSubview(textView)
    stackView.addArrangedSubview(playButton)
    stackView.addArrangedSubview(multiTrackContainer)

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

      textView.heightAnchor.constraint(equalToConstant: 120),
      playButton.heightAnchor.constraint(equalToConstant: 44),
    ])
  }
}

// UITextView placeholder extension
extension UITextView {
  private struct Placeholder {
    static var key = "placeholder"
  }

  var placeholder: String? {
    get {
      return objc_getAssociatedObject(self, &Placeholder.key) as? String
    }
    set {
      objc_setAssociatedObject(self, &Placeholder.key, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }
}
