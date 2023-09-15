//
//  SwipeCell.swift
//
//
//  Created by morse on 2023/9/15.
//

import HamsterKeyboardKit
import UIKit

private extension UIConfigurationStateCustomKey {
  static let keyOfKeyboard = UIConfigurationStateCustomKey("com.ihsiao.apps.hamster.keyboard.swipe.key")
}

private extension UICellConfigurationState {
  var key: Key? {
    set { self[.keyOfKeyboard] = newValue }
    get { return self[.keyOfKeyboard] as? Key }
  }
}

/// 划动设置 Cell
class SwipeSettingsCell: UICollectionViewListCell {
  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.key = key
    return state
  }

  private var key: Key? = nil

  /// cell 开头显示当前键的名称
  private lazy var keyNameLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()

  // 上划显示 label
  private lazy var swipeUpLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "上划："
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var swipeUpValueLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // 下划显示 label
  private lazy var swipeDownLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "下划："
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var swipeDownValueLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // make: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupView() {
    accessories = [.disclosureIndicator()]

    contentView.addSubview(keyNameLabel)
    contentView.addSubview(swipeUpLabel)
    contentView.addSubview(swipeUpValueLabel)
    contentView.addSubview(swipeDownLabel)
    contentView.addSubview(swipeDownValueLabel)

    NSLayoutConstraint.activate([
      keyNameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
      keyNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: keyNameLabel.bottomAnchor, multiplier: 1),
      keyNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),

      swipeUpLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      swipeDownLabel.topAnchor.constraint(equalTo: swipeUpLabel.bottomAnchor),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: swipeDownLabel.bottomAnchor, multiplier: 1),

      swipeUpValueLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      swipeDownValueLabel.topAnchor.constraint(equalTo: swipeUpValueLabel.bottomAnchor),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: swipeDownValueLabel.bottomAnchor, multiplier: 1),

      swipeUpLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: keyNameLabel.trailingAnchor, multiplier: 1),
      swipeDownLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: keyNameLabel.trailingAnchor, multiplier: 1),
      swipeUpLabel.widthAnchor.constraint(equalTo: swipeDownLabel.widthAnchor, multiplier: 1),

      swipeUpValueLabel.leadingAnchor.constraint(equalTo: swipeUpLabel.trailingAnchor),
      swipeDownValueLabel.leadingAnchor.constraint(equalTo: swipeDownLabel.trailingAnchor),
      swipeUpValueLabel.widthAnchor.constraint(equalTo: swipeDownValueLabel.widthAnchor, multiplier: 1),

      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: swipeUpValueLabel.trailingAnchor, multiplier: 1),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: swipeDownValueLabel.trailingAnchor, multiplier: 1),

      separatorLayoutGuide.leadingAnchor.constraint(equalTo: keyNameLabel.leadingAnchor)
    ])
  }

  /// 调用此方法更新 cell 内容
  /// 注意 updateConfiguration(using: state) 中 state 属性对应 override 改写的 configurationState
  /// 所以 state.key 就是更新后的 newkey
  func updateWithKey(_ newKey: Key) {
    guard key != newKey else { return }
    self.key = newKey
    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    keyNameLabel.text = state.key?.action.labelText
    swipeUpValueLabel.text = state.key?.swipe.first(where: { $0.direction == .up })?.action.labelText ?? " "
    swipeDownValueLabel.text = state.key?.swipe.first(where: { $0.direction == .down })?.action.labelText ?? " "
  }
}

extension KeyboardAction {
  var labelText: String {
    switch self {
    case .backspace:
      return "退格键"
    case .primary:
      return "回车键"
    case .shift:
      return "Shift"
    case .space:
      return "空格"
    case .character(let char):
      return char
    case .keyboardType(let type):
      return type.label
    default:
      return ""
    }
  }
}
