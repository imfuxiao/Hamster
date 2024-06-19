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

/// 划动设置显示 Cell
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
    label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    label.textAlignment = .left
    label.numberOfLines = 2
    label.lineBreakMode = .byCharWrapping
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()

  // 上划 label
  private lazy var swipeUpLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 2
    label.lineBreakMode = .byCharWrapping
    label.adjustsFontSizeToFitWidth = true
    label.contentScaleFactor = 0.5
    return label
  }()

  // 下划 label
  private lazy var swipeDownLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 2
    label.lineBreakMode = .byCharWrapping
    label.textAlignment = .left
    label.adjustsFontSizeToFitWidth = true
    label.contentScaleFactor = 0.5
    return label
  }()

  // 左划 label
  private lazy var swipeLeftLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 2
    label.lineBreakMode = .byCharWrapping
    label.textAlignment = .left
    label.adjustsFontSizeToFitWidth = true
    label.contentScaleFactor = 0.5
    return label
  }()

  // 右划 label
  private lazy var swipeRightLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 2
    label.lineBreakMode = .byCharWrapping
    label.textAlignment = .left
    label.adjustsFontSizeToFitWidth = true
    label.contentScaleFactor = 0.5
    return label
  }()

  private lazy var swipeLabelContainerView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [swipeUpLabel, swipeDownLabel, swipeLeftLabel, swipeRightLabel])
    view.axis = .vertical
    view.alignment = .leading
    view.distribution = .fillEqually
    view.spacing = 3
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
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
    contentView.addSubview(swipeLabelContainerView)

    NSLayoutConstraint.activate([
      keyNameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
      keyNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
      keyNameLabel.heightAnchor.constraint(equalTo: swipeLabelContainerView.heightAnchor),
      swipeLabelContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: keyNameLabel.trailingAnchor, multiplier: 1),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: swipeLabelContainerView.trailingAnchor, multiplier: 1),
      swipeLabelContainerView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: swipeLabelContainerView.bottomAnchor, multiplier: 1),
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
    keyNameLabel.text = state.key?.action.yamlString
    swipeUpLabel.text = getSwipeLabelText(key: key, direction: .up)
    swipeDownLabel.text = getSwipeLabelText(key: key, direction: .down)
    swipeLeftLabel.text = getSwipeLabelText(key: key, direction: .left)
    swipeRightLabel.text = getSwipeLabelText(key: key, direction: .right)
  }

  func getSwipeLabelText(key: Key?, direction: KeySwipe.Direction) -> String {
    if let swipe = key?.swipe.first(where: { $0.direction == direction }) {
      return "\(direction.labelText)：\(swipe.action.yamlString)"
    }
    return "\(direction.labelText)：未设置"
  }
}

extension KeyboardAction {
  var labelText: String {
    switch self {
    case .backspace:
      return L10n.KB.SwipeSetting.keyNameBackspace
    case .primary:
      return L10n.KB.SwipeSetting.keyNameReturn
    case .shift:
      return L10n.KB.SwipeSetting.keyNameShift
    case .space:
      return L10n.KB.SwipeSetting.keyNameSpace
    case .character(let char):
      return char
    case .keyboardType(let type):
      return type.label
    default:
      return ""
    }
  }
}
