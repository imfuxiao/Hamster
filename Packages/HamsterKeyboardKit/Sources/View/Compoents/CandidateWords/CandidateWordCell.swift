//
//  CandidateWordCell.swift
//
//
//  Created by morse on 2023/8/19.
//

import RimeKit
import UIKit

/**
 候选文字单元格
 */
class CandidateWordCell: UICollectionViewCell {
  private var candidateSuggestion: CandidateSuggestion? = nil
  private var keyboardColor: HamsterKeyboardColor? = nil
  private var showIndex: Bool = false
  private var showComment: Bool = false
  private var titleFont: UIFont = KeyboardFont.title3.font
  private var subtitleFont: UIFont = KeyboardFont.caption2.font

  private var candidateWidthConstraint: NSLayoutConstraint?

  public lazy var textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 1
//    label.adjustsFontSizeToFitWidth = true
//    label.minimumScaleFactor = 0.5
//    label.lineBreakMode = .byClipping
    return label
  }()

  public lazy var secondaryLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 1
//    label.adjustsFontSizeToFitWidth = true
//    label.minimumScaleFactor = 0.5
//    label.lineBreakMode = .byClipping
    return label
  }()

  private lazy var containerView: UIView = {
    let view = UIView(frame: .zero)
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupView() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    secondaryLabel.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(containerView)
    containerView.addSubview(textLabel)
    containerView.addSubview(secondaryLabel)
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),

      textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3),
      textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3),
      textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),

      secondaryLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor),
      secondaryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
      secondaryLabel.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor),
    ])
  }

  /// 当每次 CandidateSuggestion 发生变化时调用此方法，来更新 UI
  func updateWithCandidateSuggestion(
    _ suggestion: CandidateSuggestion,
    color: HamsterKeyboardColor? = nil,
    showIndex: Bool? = nil,
    showComment: Bool? = nil,
    titleFont: UIFont? = nil,
    subtitleFont: UIFont? = nil
  ) {
    self.keyboardColor = color
    if let showIndex = showIndex {
      self.showIndex = showIndex
    }
    if let showComment = showComment {
      self.showComment = showComment
    }
    if let titleFont = titleFont {
      self.titleFont = titleFont
    }
    if let subtitleFont = subtitleFont {
      self.subtitleFont = subtitleFont
    }

    guard candidateSuggestion != suggestion else { return }
    candidateSuggestion = suggestion

    // 调用此方法后，下面重载的属性 configurationState 就会包含新的 candidateSuggestion
    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    // TODO: 字体大小可配置
    let index = state.candidateSuggestion?.index
    let title = state.candidateSuggestion?.title
    if showIndex {
      textLabel.text = index == nil ? title : "\(index! + 1). \(title ?? "")"
    } else {
      textLabel.text = title
    }
    if showComment {
      secondaryLabel.text = state.candidateSuggestion?.subtitle
    } else {
      secondaryLabel.text = ""
    }

    textLabel.font = titleFont
    secondaryLabel.font = subtitleFont

    if let keyboardColor = keyboardColor {
      if state.candidateSuggestion?.isAutocomplete ?? false {
        self.textLabel.textColor = keyboardColor.hilitedCandidateTextColor
        self.secondaryLabel.textColor = keyboardColor.hilitedCommentTextColor
      } else {
        self.textLabel.textColor = keyboardColor.candidateTextColor
        self.secondaryLabel.textColor = keyboardColor.commentTextColor
      }
    }

    if (state.candidateSuggestion?.isAutocomplete ?? false) || state.isSelected || state.isHighlighted
    {
      containerView.backgroundColor = keyboardColor?.hilitedCandidateBackColor ?? UIColor.secondarySystemBackground
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
  static let candidateSuggestionItem = UIConfigurationStateCustomKey("com.ihsiao.apps.hamster.keyboard.CandidateSuggestionCell.item")
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
