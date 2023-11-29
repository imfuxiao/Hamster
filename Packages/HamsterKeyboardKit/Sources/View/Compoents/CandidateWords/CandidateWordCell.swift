//
//  CandidateWordCell.swift
//
//
//  Created by morse on 2023/8/19.
//

import UIKit

/**
 候选文字单元格
 */
class CandidateWordCell: UICollectionViewCell {
  public static let identifier = "CandidateWordCell"
  private var candidateSuggestion: CandidateSuggestion? = nil
  private var showIndex: Bool = false
  private var showComment: Bool = false
  private var style: CandidateBarStyle? = nil

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(candidateLabel)
    NSLayoutConstraint.activate([
      candidateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
      candidateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      candidateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      candidateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])
  }

  private var candidateLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 当每次 CandidateSuggestion 发生变化时调用此方法，来更新 UI
  func updateWithCandidateSuggestion(
    _ suggestion: CandidateSuggestion,
    style: CandidateBarStyle? = nil,
    showIndex: Bool? = nil,
    showComment: Bool? = nil
  ) {
    self.style = style
    if let showIndex = showIndex {
      self.showIndex = showIndex
    }
    if let showComment = showComment {
      self.showComment = showComment
    }
    guard candidateSuggestion != suggestion else { return }
    candidateSuggestion = suggestion

    // 调用此方法后，下面重载的属性 configurationState 就会包含新的 candidateSuggestion
    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    if let style = style, let attributeText = state.candidateSuggestion?.attributeString(showIndex: showIndex, showComment: showComment, style: style) {
      candidateLabel.attributedText = attributeText
    }

    var backgroundConfiguration = UIBackgroundConfiguration.clear()
    if (state.candidateSuggestion?.isAutocomplete ?? false) || state.isSelected || state.isHighlighted {
      backgroundConfiguration.cornerRadius = 5
      backgroundConfiguration.backgroundColor = style?.preferredCandidateBackgroundColor
    }

    self.backgroundConfiguration = backgroundConfiguration
  }

  /// 为 UICellConfigurationState 添加自定义属性 candidateSuggestion
  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.candidateSuggestion = candidateSuggestion
    return state
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    candidateLabel.attributedText = nil
    contentConfiguration = nil
    backgroundConfiguration = nil
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

public extension CandidateSuggestion {
  func attributeString(showIndex: Bool, showComment: Bool, style: CandidateBarStyle) -> NSAttributedString {
    let result = NSMutableAttributedString()

    let label = label.trimmingCharacters(in: .whitespaces)
    if showIndex, !label.isEmpty {
      let labelColor = isAutocomplete ? style.preferredCandidateLabelColor : style.candidateLabelColor
      let labelAttributeString = NSAttributedString(string: label, attributes: [.foregroundColor: labelColor, .font: style.candidateLabelFont])
      result.append(labelAttributeString)
    }

    let textColor = isAutocomplete ? style.preferredCandidateTextColor : style.candidateTextColor
    let textAttributeString = NSAttributedString(string: (showIndex && !label.isEmpty) ? " \(title)" : title, attributes: [.foregroundColor: textColor, .font: style.candidateTextFont])
    result.append(textAttributeString)

    if showComment, let comment = subtitle {
      let commentColor = isAutocomplete ? style.preferredCandidateCommentTextColor : style.candidateCommentTextColor
      let commentAttributeString = NSAttributedString(string: " \(comment)", attributes: [.foregroundColor: commentColor, .font: style.candidateCommentFont])
      result.append(commentAttributeString)
    }

    return result
  }
}
