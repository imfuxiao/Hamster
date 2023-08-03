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

  private let candidateAreaMargin = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

  var keyboardColor: KeyboardColor

  private let schemaNameView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = ""
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    return label
  }()

  private lazy var schemaAuthorView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = ""
    label.font = .preferredFont(forTextStyle: .subheadline)
    return label
  }()

  // 候选区域：组字子区域
  private lazy var wordLabel: UILabel = {
    let word = UILabel(frame: .zero)
    word.text = "方案"
    word.font = .preferredFont(forTextStyle: .body)
    word.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return word
  }()

  private lazy var wordPinyinLabel: UILabel = {
    let wordPinyin = UILabel(frame: .zero)
    wordPinyin.text = "pei se˰"
    wordPinyin.font = .preferredFont(forTextStyle: .body)
    return wordPinyin
  }()

  private lazy var codingAreaView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [wordLabel, wordPinyinLabel])
    stack.layoutMargins = candidateAreaMargin
    stack.isLayoutMarginsRelativeArrangement = true
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 8
    return stack
  }()

  // 候选区域：候选文字子区域
  private lazy var firstWordLabel: UILabel = {
    let firstWord = UILabel(frame: .zero)
    firstWord.text = "1. 配色"
    firstWord.font = .preferredFont(forTextStyle: .body)
    firstWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return firstWord
  }()

  private lazy var firstWordPinyinLabel: UILabel = {
    let firstWordPinyin = UILabel(frame: .zero)
    firstWordPinyin.text = "(pei se)"
    firstWordPinyin.font = .preferredFont(forTextStyle: .body)
    firstWordPinyin.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return firstWordPinyin
  }()

  private lazy var secondaryWordLabel: UILabel = {
    let secondaryWord = UILabel(frame: .zero)
    secondaryWord.text = "2. 陪"
    secondaryWord.font = .preferredFont(forTextStyle: .body)
    secondaryWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return secondaryWord
  }()

  private lazy var secondaryWordPinyinLabel: UILabel = {
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
    firstContainer.spacing = 8
    firstContainer.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return firstContainer
  }()

  private lazy var secondaryWordContainer: UIStackView = {
    let secondaryContainer = UIStackView(arrangedSubviews: [secondaryWordLabel, secondaryWordPinyinLabel])
    secondaryContainer.axis = .horizontal
    secondaryContainer.alignment = .leading
    secondaryContainer.distribution = .fill
    secondaryContainer.spacing = 8
    return secondaryContainer
  }()

  private lazy var selectAreaView: UIView = {
    let stack = UIStackView(arrangedSubviews: [firstWordContainer, secondaryWordContainer])
    stack.layoutMargins = candidateAreaMargin
    stack.isLayoutMarginsRelativeArrangement = true
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
    stack.spacing = 0

    stack.layer.cornerRadius = 10
    stack.layer.masksToBounds = true
    return stack
  }()

  // 预览区域
  private lazy var previewView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [schemaNameView, schemaAuthorView, candidateAreaView])
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 3
    stack.layoutMargins = candidateAreaMargin
    stack.isLayoutMarginsRelativeArrangement = true
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
    previewView.fillSuperview()
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
    schemaNameView.text = ""
    schemaAuthorView.text = ""

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
