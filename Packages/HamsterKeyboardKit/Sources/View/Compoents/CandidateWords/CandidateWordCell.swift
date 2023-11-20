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
  private var candidateSuggestion: CandidateSuggestion? = nil
  private var showIndex: Bool = false
  private var showComment: Bool = false
  private var style: CandidateBarStyle? = nil

  private var textLabelCenterXContainer: NSLayoutConstraint?

  public lazy var textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 1
//    label.adjustsFontSizeToFitWidth = true
//    label.minimumScaleFactor = 0.8
    label.lineBreakMode = .byTruncatingTail
//    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return label
  }()

  public lazy var secondaryLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 1
//    label.adjustsFontSizeToFitWidth = true
//    label.minimumScaleFactor = 0.8
//    label.lineBreakMode = .byClipping
    label.lineBreakMode = .byTruncatingTail
//    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return label
  }()

//  private lazy var containerView: UIView = {
//    let stackView = UIStackView(arrangedSubviews: [textLabel, secondaryLabel])
//    stackView.axis = .horizontal
//    stackView.alignment = .firstBaseline
//    stackView.distribution = .fill
//    stackView.spacing = 0
//
//    let centerView = UIStackView(arrangedSubviews: [stackView])
//    centerView.axis = .horizontal
//    centerView.alignment = .center
//    centerView.distribution = .equalSpacing
//    centerView.spacing = 0
  ////    centerView.isLayoutMarginsRelativeArrangement = true
  ////    centerView.layoutMargins = .horizontal(8, vertical: 6)
//    return centerView
//  }()

  private lazy var containerView: UIView = {
    let containerView = UIView(frame: .zero)

    containerView.addSubview(textLabel)
    containerView.addSubview(secondaryLabel)

    containerView.translatesAutoresizingMaskIntoConstraints = false
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    secondaryLabel.translatesAutoresizingMaskIntoConstraints = false

    textLabelCenterXContainer = textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
    textLabelCenterXContainer?.priority = .required

    NSLayoutConstraint.activate([
      textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
      secondaryLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor),
      secondaryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),

      textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      secondaryLabel.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor),

      textLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1),
      secondaryLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1),

      textLabelCenterXContainer!,
    ])

    let stackView = UIStackView(arrangedSubviews: [containerView])
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 0
    return stackView
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
//    containerView.translatesAutoresizingMaskIntoConstraints = false
//    contentView.addSubview(containerView)
//    NSLayoutConstraint.activate([
//      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
//      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//    ])
    contentView.addSubview(containerView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
      containerView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
    ])
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
    let title = state.candidateSuggestion?.title ?? ""
    let index = state.candidateSuggestion?.showIndexLabel ?? ""
    if showIndex {
      textLabel.text = index.isEmpty ? title : "\(index) \(title)"
    } else {
      textLabel.text = title
    }
    if showComment {
      secondaryLabel.text = state.candidateSuggestion?.subtitle
    } else {
      secondaryLabel.text = ""
    }

    textLabelCenterXContainer?.isActive = secondaryLabel.text?.isEmpty ?? true

    if let style = style {
      textLabel.font = style.candidateTextFont
      secondaryLabel.font = style.candidateCommentFont
      if state.candidateSuggestion?.isAutocomplete ?? false {
        self.textLabel.textColor = style.preferredCandidateTextColor
        self.secondaryLabel.textColor = style.preferredCandidateCommentTextColor
      } else {
        self.textLabel.textColor = style.candidateTextColor
        self.secondaryLabel.textColor = style.candidateCommentTextColor
      }
    }

    if (state.candidateSuggestion?.isAutocomplete ?? false) || state.isSelected || state.isHighlighted
    {
      containerView.layer.cornerRadius = 5
      containerView.backgroundColor = style?.preferredCandidateBackgroundColor
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

  override func prepareForReuse() {
    super.prepareForReuse()

    textLabel.text = ""
    secondaryLabel.text = ""
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
