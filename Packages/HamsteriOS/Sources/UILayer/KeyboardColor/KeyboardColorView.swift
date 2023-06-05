//
//  ColorSchemaView.swift
//  Hamster
//
//  Created by morse on 2023/6/19.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

class KeyboardColorView: NibLessView {
  // MARK: properties

  var keyboardColor: HamsterKeyboardColor

  private let schemaNameView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "方案名称："
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    return label
  }()

  private let schemaAuthorView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "作者："
    label.font = .preferredFont(forTextStyle: .subheadline)
    return label
  }()

  // 候选区域：组字子区域
  private let wordLabel: UILabel = {
    let word = UILabel(frame: .zero)
    word.text = "方案"
    word.font = .preferredFont(forTextStyle: .body)
    word.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return word
  }()

  private let wordPinyinLabel: UILabel = {
    let wordPinyin = UILabel(frame: .zero)
    wordPinyin.text = "pei se˰"
    wordPinyin.font = .preferredFont(forTextStyle: .body)
    return wordPinyin
  }()

  private lazy var codingAreaView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [wordLabel, wordPinyinLabel])
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.distribution = .fill
    return stack
  }()

  // 候选区域：候选文字子区域
  private let firstWordLabel: UILabel = {
    let firstWord = UILabel(frame: .zero)
    firstWord.text = "1. 配色"
    firstWord.font = .preferredFont(forTextStyle: .body)
    firstWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return firstWord
  }()

  private let firstWordPinyinLabel: UILabel = {
    let firstWordPinyin = UILabel(frame: .zero)
    firstWordPinyin.text = "(pei se)"
    firstWordPinyin.font = .preferredFont(forTextStyle: .body)
    firstWordPinyin.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return firstWordPinyin
  }()

  private let secondaryWordLabel: UILabel = {
    let secondaryWord = UILabel(frame: .zero)
    secondaryWord.text = "2. 陪"
    secondaryWord.font = .preferredFont(forTextStyle: .body)
    secondaryWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return secondaryWord
  }()

  private let secondaryWordPinyinLabel: UILabel = {
    let secondaryWordPinyin = UILabel(frame: .zero)
    secondaryWordPinyin.text = "(pei)"
    secondaryWordPinyin.font = .preferredFont(forTextStyle: .body)
    return secondaryWordPinyin
  }()

  private lazy var firstWordContainer: UIStackView = {
    let firstContainer = UIStackView(arrangedSubviews: [firstWordLabel, firstWordPinyinLabel])
    firstContainer.axis = .horizontal
    firstContainer.alignment = .leading
    firstContainer.distribution = .fill
    firstContainer.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return firstContainer
  }()

  private lazy var secondaryWordContainer: UIStackView = {
    let secondaryContainer = UIStackView(arrangedSubviews: [secondaryWordLabel, secondaryWordPinyinLabel])
    secondaryContainer.axis = .horizontal
    secondaryContainer.alignment = .leading
    secondaryContainer.distribution = .fill
    return secondaryContainer
  }()

  private lazy var selectAreaView: UIView = {
    let stack = UIStackView(arrangedSubviews: [firstWordContainer, secondaryWordContainer])
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 8
    return stack
  }()

  // 候选区域
  private lazy var candidateAreaView = {
    let stack = UIStackView(arrangedSubviews: [codingAreaView, selectAreaView])
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.layer.cornerRadius = 10
    stack.layer.masksToBounds = true
    stack.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
    stack.isLayoutMarginsRelativeArrangement = true
    return stack
  }()

  // MARK: methods

  init(
    frame: CGRect = .zero,
    colorSchema: HamsterKeyboardColor)
  {
    self.keyboardColor = colorSchema

    super.init(frame: frame)

    setupSubview()
  }

  func setupSubview() {
    addSubview(schemaNameView)
    addSubview(schemaAuthorView)
    addSubview(candidateAreaView)

    schemaNameView.translatesAutoresizingMaskIntoConstraints = false
    schemaAuthorView.translatesAutoresizingMaskIntoConstraints = false
    candidateAreaView.translatesAutoresizingMaskIntoConstraints = false

    let layoutGuide = layoutMarginsGuide

    NSLayoutConstraint.activate([
      schemaNameView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      schemaNameView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      schemaNameView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),

      schemaAuthorView.topAnchor.constraint(equalToSystemSpacingBelow: schemaNameView.bottomAnchor, multiplier: 1.5),
      schemaAuthorView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      schemaAuthorView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),

      candidateAreaView.topAnchor.constraint(equalToSystemSpacingBelow: schemaAuthorView.bottomAnchor, multiplier: 1.5),
      candidateAreaView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      candidateAreaView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
      candidateAreaView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
    ])
  }

  func updatePreviewColor() {
    schemaNameView.text = "方案名称: \(keyboardColor.name)"
    schemaAuthorView.text = "作者: \(keyboardColor.author)"

    wordLabel.textColor = keyboardColor.textColor
    wordPinyinLabel.textColor = keyboardColor.textColor
//    codingAreaView.backgroundColor = keyboardColor.hilitedBackColor

    firstWordLabel.textColor = keyboardColor.hilitedCandidateTextColor
    firstWordPinyinLabel.textColor = keyboardColor.hilitedCommentTextColor
    firstWordContainer.backgroundColor = keyboardColor.hilitedCandidateBackColor

    secondaryWordLabel.textColor = keyboardColor.candidateTextColor
    secondaryWordPinyinLabel.textColor = keyboardColor.commentTextColor

    candidateAreaView.backgroundColor = keyboardColor.backColor
  }

  func cleanPreviewColor() {
    schemaNameView.text = "方案名称: "
    schemaAuthorView.text = "作者: "

    wordLabel.textColor = .clear
    wordPinyinLabel.textColor = .clear
    codingAreaView.backgroundColor = .clear

    firstWordLabel.textColor = .clear
    firstWordPinyinLabel.textColor = .clear
    firstWordContainer.backgroundColor = .clear

    secondaryWordLabel.textColor = .clear
    secondaryWordPinyinLabel.textColor = .clear

    candidateAreaView.backgroundColor = .black
  }
}
