//
//  CloudInputSchemaDetailView.swift
//
//
//  Created by morse on 2023/11/12.
//

import HamsterUIKit
import UIKit

class CloudInputSchemaInfoView: NibLessView {
  private let inputSchemaInfo: InputSchemaViewModel.InputSchemaInfo
  private let inputSchemaViewModel: InputSchemaViewModel

  private lazy var titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingMiddle
    label.textColor = UIColor.label
    label.font = UIFont.preferredFont(forTextStyle: .title3)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    return label
  }()

  private lazy var authorLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.textColor = UIColor.secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    return label
  }()

  private lazy var descLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .justified
    label.numberOfLines = -1
    label.lineBreakMode = .byTruncatingTail
    label.textColor = UIColor.secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var separatorView: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = UIColor.separator
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  public lazy var replaceInstallButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setTitle("替换并部署", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.backgroundColor = UIColor.systemBackground
    button.layer.cornerRadius = 5
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(installInputSchemaByReplace(_:)), for: .touchUpInside)
    return button
  }()

  public lazy var overwriteInstallButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setTitle("覆盖并部署", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.backgroundColor = UIColor.systemBackground
    button.layer.cornerRadius = 5
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(installInputSchemaByOverwrite(_:)), for: .touchUpInside)
    return button
  }()

  public lazy var remarkLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "替换：删除当前 Rime 路径下文件，并将下载的方案文件存放至 Rime 路径下。\n覆盖：将下载方案文件存放至 Rime 目录下，相同文件名称文件覆盖，不同文件追加。"
    label.textAlignment = .justified
    label.numberOfLines = -1
    label.lineBreakMode = .byTruncatingTail
    label.textColor = UIColor.secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  public lazy var scrollView: UIScrollView = {
    let view = UIScrollView(frame: .zero)
    view.isScrollEnabled = true
    view.alwaysBounceVertical = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init(inputSchemaInfo: InputSchemaViewModel.InputSchemaInfo, inputSchemaViewModel: InputSchemaViewModel) {
    self.inputSchemaInfo = inputSchemaInfo
    self.inputSchemaViewModel = inputSchemaViewModel

    super.init(frame: .zero)

    constructViewHierarchy()
    activateViewConstraints()
    setupAppearance()
  }

  override func constructViewHierarchy() {
    addSubview(scrollView)

    scrollView.addSubview(titleLabel)
    scrollView.addSubview(authorLabel)
    scrollView.addSubview(separatorView)
    scrollView.addSubview(descLabel)

    addSubview(replaceInstallButton)
    addSubview(overwriteInstallButton)
    addSubview(remarkLabel)
  }

  override func activateViewConstraints() {
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: replaceInstallButton.topAnchor),

      scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),

      replaceInstallButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
      trailingAnchor.constraint(equalToSystemSpacingAfter: replaceInstallButton.trailingAnchor, multiplier: 1),

      overwriteInstallButton.topAnchor.constraint(equalToSystemSpacingBelow: replaceInstallButton.bottomAnchor, multiplier: 1.0),
      overwriteInstallButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
      trailingAnchor.constraint(equalToSystemSpacingAfter: overwriteInstallButton.trailingAnchor, multiplier: 1),

      remarkLabel.topAnchor.constraint(equalToSystemSpacingBelow: overwriteInstallButton.bottomAnchor, multiplier: 1),
      remarkLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
      trailingAnchor.constraint(equalToSystemSpacingAfter: remarkLabel.trailingAnchor, multiplier: 1),
      safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: remarkLabel.bottomAnchor, multiplier: 1),

      titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: scrollView.contentLayoutGuide.topAnchor, multiplier: 2),
      titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1),

      authorLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
      authorLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: authorLabel.trailingAnchor, multiplier: 1),

      separatorView.heightAnchor.constraint(equalToConstant: 1),
      separatorView.topAnchor.constraint(equalToSystemSpacingBelow: authorLabel.bottomAnchor, multiplier: 1),
      separatorView.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: separatorView.trailingAnchor, multiplier: 1),

      descLabel.topAnchor.constraint(equalToSystemSpacingBelow: separatorView.bottomAnchor, multiplier: 1),
      descLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: descLabel.trailingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: descLabel.bottomAnchor, multiplier: 1),
    ])
  }

  override func setupAppearance() {
    backgroundColor = .secondarySystemBackground

    titleLabel.text = inputSchemaInfo.title
    authorLabel.text = inputSchemaInfo.author
    descLabel.text = inputSchemaInfo.description
  }

  @objc func installInputSchemaByOverwrite(_ sender: Any) {
    inputSchemaViewModel.installInputSchemaSubject.send((.overwrite, inputSchemaInfo))
  }

  @objc func installInputSchemaByReplace(_ sender: Any) {
    inputSchemaViewModel.installInputSchemaSubject.send((.replace, inputSchemaInfo))
  }
}
