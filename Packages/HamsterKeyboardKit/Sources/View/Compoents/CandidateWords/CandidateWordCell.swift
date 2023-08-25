//
//  CandidateWordCell.swift
//
//
//  Created by morse on 2023/8/19.
//

import HamsterModel
import UIKit

/**
 候选文字单元格
 */
class CandidateWordCell: UICollectionViewCell {
  private lazy var listContentView = UIListContentView(configuration: contentConfiguration())

  public lazy var textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 1
    return label
  }()

  public lazy var secondaryLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 1
    return label
  }()

  private lazy var containerView: UIView = {
    let view = UIView(frame: .zero)
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    containerView.translatesAutoresizingMaskIntoConstraints = false
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    secondaryLabel.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(containerView)
    containerView.addSubview(textLabel)
    containerView.addSubview(secondaryLabel)
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),

      textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
      textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
      textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),

      secondaryLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor),
      secondaryLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
      secondaryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var candidateSuggestion: CandidateSuggestion? = nil
  private var keyboardColor: HamsterModel.KeyboardColor? = nil

  /// 当每次 CandidateSuggestion 发生变化时调用此方法，来更新 UI
  func updateWithCandidateSuggestion(_ suggestion: CandidateSuggestion, color: HamsterModel.KeyboardColor? = nil) {
    keyboardColor = color
    guard candidateSuggestion != suggestion else { return }
    candidateSuggestion = suggestion
    keyboardColor = color

    // 调用此方法后，下面重载的属性 configurationState 就会包含新的 candidateSuggestion
    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    // TODO: 字体大小可配置
    textLabel.text = state.candidateSuggestion?.title
    textLabel.font = KeyboardFont.title3.font

    secondaryLabel.text = state.candidateSuggestion?.subtitle
    secondaryLabel.font = KeyboardFont.caption2.font

    if (state.candidateSuggestion?.isAutocomplete ?? false) || state.isSelected || state.isHighlighted {
      containerView.backgroundColor = keyboardColor?.hilitedCandidateBackColor ?? UIColor.systemGroupedBackground
      containerView.layer.cornerRadius = 5
    } else {
      containerView.backgroundColor = .clear
    }
  }

  /// 为 UICellConfigurationState 添加自定义属性 candidateSuggestion
  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.candidateSuggestion = candidateSuggestion
    return state
  }

  /// 返回具有并排值文本的列表单元格的默认配置。
  private func contentConfiguration() -> UIListContentConfiguration {
    .valueCell()
  }
}

/// 扩展 UIConfigurationStateCustomKey，用来表示 state 中自定义的数据
private extension UIConfigurationStateCustomKey {
  static let candidateSuggestionItem = UIConfigurationStateCustomKey("com.ihsiao.apps.hamster.keyboard.CandidateSuggestionCell")
}

/// 扩展 UICellConfigurationState，添加自定义数据属性
private extension UICellConfigurationState {
  var candidateSuggestion: CandidateSuggestion? {
    get {
      self[.candidateSuggestionItem] as? CandidateSuggestion
    }
    set {
      self[.candidateSuggestionItem] = newValue
    }
  }
}
