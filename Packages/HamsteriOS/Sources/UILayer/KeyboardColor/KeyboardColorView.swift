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
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    return label
  }()

  private let schemaAuthorView: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = .preferredFont(forTextStyle: .subheadline)
    return label
  }()

  // 候选区域：组字子区域
  private let phoneticLabel: UILabel = {
    let word = UILabel(frame: .zero)
    word.font = .preferredFont(forTextStyle: .body)
    word.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return word
  }()

  // 候选区域：候选文字子区域
  private let candidateLabel: UILabel = {
    let firstWord = UILabel(frame: .zero)
    firstWord.font = .preferredFont(forTextStyle: .body)
    firstWord.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return firstWord
  }()

  // 候选区域
  private lazy var candidateAreaView = {
    let stack = UIStackView(arrangedSubviews: [phoneticLabel, candidateLabel])
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fillEqually
    stack.layer.cornerRadius = 10
    stack.layer.masksToBounds = true
    stack.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
    stack.isLayoutMarginsRelativeArrangement = true
    return stack
  }()

  // MARK: methods

  init(
    frame: CGRect = .zero,
    colorSchema: HamsterKeyboardColor
  ) {
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

    phoneticLabel.text = "方案 pei se"
    phoneticLabel.textColor = keyboardColor.textColor

    let candidateAttributeString = NSMutableAttributedString()

    candidateAttributeString.append(NSAttributedString(
      string: "1",
      attributes: [.foregroundColor: keyboardColor.hilitedCandidateLabelColor]
    ))
    candidateAttributeString.append(NSAttributedString(
      string: " 配色",
      attributes: [.foregroundColor: keyboardColor.hilitedCandidateTextColor]
    ))
    candidateAttributeString.append(NSAttributedString(
      string: " (pei se)",
      attributes: [.foregroundColor: keyboardColor.hilitedCommentTextColor]
    ))

    candidateAttributeString.append(NSAttributedString(
      string: "2",
      attributes: [.foregroundColor: keyboardColor.labelColor]
    ))
    candidateAttributeString.append(NSAttributedString(
      string: " 陪",
      attributes: [.foregroundColor: keyboardColor.textColor]
    ))
    candidateAttributeString.append(NSAttributedString(
      string: " (pei)",
      attributes: [.foregroundColor: keyboardColor.commentTextColor]
    ))

    candidateLabel.attributedText = candidateAttributeString

    candidateAreaView.backgroundColor = keyboardColor.backColor
  }

  func cleanPreviewColor() {
    schemaNameView.text = "方案名称: "
    schemaAuthorView.text = "作者: "

    phoneticLabel.textColor = .clear
    candidateLabel.textColor = .clear
    candidateAreaView.backgroundColor = .clear
  }
}
