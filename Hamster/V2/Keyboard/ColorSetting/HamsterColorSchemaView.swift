//
//  ColorSchemaView.swift
//  Hamster
//
//  Created by morse on 2023/6/19.
//

import UIKit

class HamsterColorSchemaView: UIView {
  init(colorSchema: HamsterColorSchema) {
    self.colorSchema = colorSchema
    super.init(frame: .zero)

    addSubview(colorSchemaPreviewView)
    NSLayoutConstraint.activate([
      colorSchemaPreviewView.topAnchor.constraint(equalTo: topAnchor),
      colorSchemaPreviewView.bottomAnchor.constraint(equalTo: bottomAnchor),
      colorSchemaPreviewView.leadingAnchor.constraint(equalTo: leadingAnchor),
      colorSchemaPreviewView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
    self.translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func initSubview() {}

  private let colorSchema: HamsterColorSchema

  private lazy var colorSchemaPreviewView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 3

    stack.addArrangedSubview(schemaNameView)
    stack.addArrangedSubview(schemaAuthorView)
    stack.addArrangedSubview(candidateAreaView)

    stack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    stack.isLayoutMarginsRelativeArrangement = true

    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      candidateAreaView.leadingAnchor.constraint(equalToSystemSpacingAfter: stack.leadingAnchor, multiplier: 1.0),
      stack.trailingAnchor.constraint(equalToSystemSpacingAfter: candidateAreaView.trailingAnchor, multiplier: 1.0),
    ])
    return stack
  }()

  private lazy var schemaNameView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "方案名称: \(colorSchema.name)"
    label.font = .preferredFont(forTextStyle: .headline)
    return label
  }()

  private lazy var schemaAuthorView: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "作者: \(colorSchema.author)"
    label.font = .preferredFont(forTextStyle: .subheadline)
    return label
  }()

  // 组字区域
  private lazy var codingAreaView: UIStackView = {
    let word = UILabel(frame: .zero)
    word.text = "方案"
    word.font = .preferredFont(forTextStyle: .body)
    word.textColor = UIColor(colorSchema.textColor)
    word.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let wordPinyin = UILabel(frame: .zero)
    wordPinyin.text = "pei se˰"
    wordPinyin.font = .preferredFont(forTextStyle: .body)
    wordPinyin.textColor = UIColor(colorSchema.hilitedTextColor)

    let stack = UIStackView(arrangedSubviews: [word, wordPinyin])
    stack.isLayoutMarginsRelativeArrangement = true
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
    firstWord.textColor = UIColor(colorSchema.hilitedCandidateTextColor)
    firstWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let firstWordPinyin = UILabel(frame: .zero)
    firstWordPinyin.text = "(pei se)"
    firstWordPinyin.font = .preferredFont(forTextStyle: .body)
    firstWordPinyin.textColor = UIColor(colorSchema.hilitedCommentTextColor)
    firstWordPinyin.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let firstContainer = UIStackView(arrangedSubviews: [firstWord, firstWordPinyin])
    firstContainer.axis = .horizontal
    firstContainer.alignment = .leading
    firstContainer.distribution = .fill
    firstContainer.spacing = 8
    firstContainer.backgroundColor = UIColor(colorSchema.hilitedCandidateBackColor)
    firstContainer.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    firstContainer.translatesAutoresizingMaskIntoConstraints = false

    let secondaryWord = UILabel(frame: .zero)
    secondaryWord.text = "2. 陪"
    secondaryWord.font = .preferredFont(forTextStyle: .body)
    secondaryWord.textColor = UIColor(colorSchema.candidateTextColor)
    secondaryWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    secondaryWord.translatesAutoresizingMaskIntoConstraints = false

    let secondaryWordPinyin = UILabel(frame: .zero)
    secondaryWordPinyin.text = "(pei)"
    secondaryWordPinyin.font = .preferredFont(forTextStyle: .body)
    secondaryWordPinyin.textColor = UIColor(colorSchema.commentTextColor)
    secondaryWordPinyin.translatesAutoresizingMaskIntoConstraints = false

    let secondaryStack = UIStackView(arrangedSubviews: [secondaryWord, secondaryWordPinyin])
    secondaryStack.axis = .horizontal
    secondaryStack.alignment = .leading
    secondaryStack.distribution = .fill
    secondaryStack.spacing = 8
    secondaryStack.translatesAutoresizingMaskIntoConstraints = false

    let stack = UIStackView()
    stack.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
    stack.isLayoutMarginsRelativeArrangement = true
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false

    stack.addArrangedSubview(firstContainer)
    stack.addArrangedSubview(secondaryStack)
    return stack
  }()

  private lazy var candidateAreaView = {
    let stack = UIStackView(arrangedSubviews: [codingAreaView, selectAreaView])
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 0

    stack.backgroundColor = UIColor(colorSchema.backColor)
    stack.layer.cornerRadius = 10
    stack.layer.masksToBounds = true

    NSLayoutConstraint.activate([
      codingAreaView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
      codingAreaView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
      selectAreaView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
      selectAreaView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
    ])
    return stack
  }()
}
