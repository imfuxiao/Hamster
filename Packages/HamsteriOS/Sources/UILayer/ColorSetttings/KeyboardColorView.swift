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

  private let keyboardColor: KeyboardColor

  private lazy var candidateAreaView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 0

    stack.backgroundColor = keyboardColor.backColor
    stack.layer.cornerRadius = 10
    stack.layer.masksToBounds = true
    return stack
  }()

  private lazy var schemaNameView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "方案名称: \(keyboardColor.name)"
    label.font = .preferredFont(forTextStyle: .headline)
    return label
  }()

  private lazy var schemaAuthorView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "作者: \(keyboardColor.author)"
    label.font = .preferredFont(forTextStyle: .subheadline)
    return label
  }()

  // 组字区域
  private lazy var codingAreaView: UIStackView = {
    let word = UILabel(frame: .zero)
    word.text = "方案"
    word.font = .preferredFont(forTextStyle: .body)
    word.textColor = keyboardColor.textColor
    word.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let wordPinyin = UILabel(frame: .zero)
    wordPinyin.text = "pei se˰"
    wordPinyin.font = .preferredFont(forTextStyle: .body)
    wordPinyin.textColor = keyboardColor.hilitedTextColor

    let stack = UIStackView(arrangedSubviews: [word, wordPinyin])
    stack.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 8
    return stack
  }()

  private lazy var selectAreaView: UIView = {
    let firstWord = UILabel(frame: .zero)
    firstWord.text = "1. 配色"
    firstWord.font = .preferredFont(forTextStyle: .body)
    firstWord.textColor = keyboardColor.hilitedCandidateTextColor
    firstWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let firstWordPinyin = UILabel(frame: .zero)
    firstWordPinyin.text = "(pei se)"
    firstWordPinyin.font = .preferredFont(forTextStyle: .body)
    firstWordPinyin.textColor = keyboardColor.hilitedCommentTextColor
    firstWordPinyin.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let firstContainer = UIStackView(arrangedSubviews: [firstWord, firstWordPinyin])
    firstContainer.axis = .horizontal
    firstContainer.alignment = .leading
    firstContainer.distribution = .fill
    firstContainer.spacing = 8
    firstContainer.backgroundColor = keyboardColor.hilitedCandidateBackColor
    firstContainer.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let secondaryWord = UILabel(frame: .zero)
    secondaryWord.text = "2. 陪"
    secondaryWord.font = .preferredFont(forTextStyle: .body)
    secondaryWord.textColor = keyboardColor.candidateTextColor
    secondaryWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let secondaryWordPinyin = UILabel(frame: .zero)
    secondaryWordPinyin.text = "(pei)"
    secondaryWordPinyin.font = .preferredFont(forTextStyle: .body)
    secondaryWordPinyin.textColor = keyboardColor.commentTextColor

    let secondaryStack = UIStackView(arrangedSubviews: [secondaryWord, secondaryWordPinyin])
    secondaryStack.axis = .horizontal
    secondaryStack.alignment = .leading
    secondaryStack.distribution = .fill
    secondaryStack.spacing = 8

    let stack = UIStackView()
    stack.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
    stack.isLayoutMarginsRelativeArrangement = true
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 8

    stack.addArrangedSubview(firstContainer)
    stack.addArrangedSubview(secondaryStack)
    return stack
  }()

  // 颜色预览区域
  private lazy var colorSchemaPreviewView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 3

    stack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    stack.isLayoutMarginsRelativeArrangement = true

    return stack
  }()

  // MARK: methods

  init(frame: CGRect = .zero, colorSchema: KeyboardColor) {
    self.keyboardColor = colorSchema

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    candidateAreaView.addArrangedSubview(codingAreaView)
    candidateAreaView.addArrangedSubview(selectAreaView)

    colorSchemaPreviewView.addArrangedSubview(schemaNameView)
    colorSchemaPreviewView.addArrangedSubview(schemaAuthorView)
    colorSchemaPreviewView.addArrangedSubview(candidateAreaView)

    addSubview(colorSchemaPreviewView)
  }

  override func activateViewConstraints() {
    codingAreaView.translatesAutoresizingMaskIntoConstraints = false
    selectAreaView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      codingAreaView.leadingAnchor.constraint(equalTo: candidateAreaView.leadingAnchor),
      codingAreaView.trailingAnchor.constraint(equalTo: candidateAreaView.trailingAnchor),
      selectAreaView.leadingAnchor.constraint(equalTo: candidateAreaView.leadingAnchor),
      selectAreaView.trailingAnchor.constraint(equalTo: candidateAreaView.trailingAnchor),
    ])

    colorSchemaPreviewView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      candidateAreaView.leadingAnchor.constraint(equalToSystemSpacingAfter: colorSchemaPreviewView.leadingAnchor, multiplier: 1.0),
      colorSchemaPreviewView.trailingAnchor.constraint(equalToSystemSpacingAfter: candidateAreaView.trailingAnchor, multiplier: 1.0),
    ])

    colorSchemaPreviewView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      colorSchemaPreviewView.topAnchor.constraint(equalTo: topAnchor),
      colorSchemaPreviewView.bottomAnchor.constraint(equalTo: bottomAnchor),
      colorSchemaPreviewView.leadingAnchor.constraint(equalTo: leadingAnchor),
      colorSchemaPreviewView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()
  }
}
