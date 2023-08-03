//
//  ColorSchemaView.swift
//  Hamster
//
//  Created by morse on 2023/6/19.
//

import HamsterModel
import HamsterUIKit
import UIKit

class KeyboardColorView: NibLessView {
  // MARK: properties

  var keyboardColor: KeyboardColor

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

  // 预览区域
  private lazy var previewView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [schemaNameView, schemaAuthorView, candidateAreaView])
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill

    schemaNameView.translatesAutoresizingMaskIntoConstraints = false
    schemaAuthorView.translatesAutoresizingMaskIntoConstraints = false
    candidateAreaView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      schemaNameView.topAnchor.constraint(equalTo: stack.topAnchor),
      schemaNameView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
      schemaNameView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

      schemaAuthorView.topAnchor.constraint(equalTo: schemaNameView.bottomAnchor),
      schemaAuthorView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
      schemaAuthorView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

      candidateAreaView.topAnchor.constraint(equalTo: schemaAuthorView.bottomAnchor),
      candidateAreaView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
      candidateAreaView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
      candidateAreaView.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
    ])

    return stack
  }()

  // MARK: methods

  init(
    frame: CGRect = .zero,
    colorSchema: KeyboardColor = KeyboardColor(name: "", colorSchema: .init(name: "")))
  {
    self.keyboardColor = colorSchema

    super.init(frame: frame)

    setupSubview()
  }

  func setupSubview() {
    addSubview(previewView)
    previewView.fillSuperviewOnMarginsGuide()
  }

  func updatePreviewColor() {
    schemaNameView.text = "方案名称: \(keyboardColor.name)"
    schemaAuthorView.text = "作者: \(keyboardColor.author)"

    wordLabel.textColor = keyboardColor.textColor
    wordPinyinLabel.textColor = keyboardColor.hilitedTextColor
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
