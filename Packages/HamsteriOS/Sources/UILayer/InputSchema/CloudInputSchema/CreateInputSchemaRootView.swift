//
//  UploadInputSchemaRootView.swift
//
//
//  Created by morse on 2023/11/13.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

class CreateInputSchemaRootView: NibLessView {
  private let inputSchemaViewModel: InputSchemaViewModel
  private var inputSchemaFileURL: URL?
  private var subscriptions = Set<AnyCancellable>()

  private lazy var titleField: UITextField = {
    let field = UITextField(frame: .zero)
    field.translatesAutoresizingMaskIntoConstraints = false
    field.leftViewMode = .always
    field.placeholder = "输入方案名称"
    field.clearButtonMode = .whileEditing
    field.borderStyle = .roundedRect
    field.leftView = UIImageView(image: UIImage(systemName: "square.and.pencil"))
    return field
  }()

  private lazy var authorField: UITextField = {
    let field = UITextField(frame: .zero)
    field.translatesAutoresizingMaskIntoConstraints = false
    field.leftViewMode = .always
    field.placeholder = "作者"
    field.clearButtonMode = .whileEditing
    field.borderStyle = .roundedRect
    field.leftView = UIImageView(image: UIImage(systemName: "square.and.pencil"))
    return field
  }()

  private lazy var descriptionLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.textColor = UIColor.secondaryLabel
    label.text = "方案描述："
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    return label
  }()

  private lazy var descriptionTextView: UITextView = {
    let textView = UITextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.backgroundColor = UIColor.systemBackground
    textView.textColor = UIColor.label
    textView.textAlignment = .left
    textView.isEditable = true
    textView.isSelectable = true
    textView.isScrollEnabled = true
    return textView
  }()

  public lazy var inputSchemaFileDocumentPickButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setTitle("选择输入方案Zip文件", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.backgroundColor = UIColor.systemBackground
    button.layer.cornerRadius = 5
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(presentDocumentPickerView(_:)), for: .touchUpInside)
    return button
  }()

  public lazy var uploadButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setImage(UIImage(systemName: "icloud.and.arrow.up.fill"), for: .normal)
    button.setTitle("上传", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.backgroundColor = UIColor.systemBackground
    button.layer.cornerRadius = 5
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(uploadInputSchema(_:)), for: .touchUpInside)
    return button
  }()

  public lazy var remarkLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "注意：请勿上传无版权输入方案。\n\(InputSchemaViewModel.copyright)"
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

  init(inputSchemaViewModel: InputSchemaViewModel) {
    self.inputSchemaViewModel = inputSchemaViewModel

    super.init(frame: .zero)

    constructViewHierarchy()
    activateViewConstraints()
    setupAppearance()
    combine()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if let _ = window {
      ProgressHUD.banner("请注意", "请勿上传非自己创作且无版权的输入方案，不符合规范的方案会被定期删除。", delay: 5)
    }
  }

  override func constructViewHierarchy() {
    addSubview(scrollView)

    scrollView.addSubview(titleField)
    scrollView.addSubview(authorField)
    scrollView.addSubview(descriptionLabel)
    scrollView.addSubview(descriptionTextView)
    scrollView.addSubview(inputSchemaFileDocumentPickButton)
    scrollView.addSubview(uploadButton)
    scrollView.addSubview(remarkLabel)
  }

  override func activateViewConstraints() {
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

      scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),

      titleField.topAnchor.constraint(equalToSystemSpacingBelow: scrollView.contentLayoutGuide.topAnchor, multiplier: 2),
      titleField.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleField.trailingAnchor, multiplier: 1),

      authorField.topAnchor.constraint(equalToSystemSpacingBelow: titleField.bottomAnchor, multiplier: 1),
      authorField.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: authorField.trailingAnchor, multiplier: 1),

      descriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: authorField.bottomAnchor, multiplier: 1),
      descriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: descriptionLabel.trailingAnchor, multiplier: 1),

      descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
      descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
      descriptionTextView.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: descriptionTextView.trailingAnchor, multiplier: 1),

      inputSchemaFileDocumentPickButton.topAnchor.constraint(equalToSystemSpacingBelow: descriptionTextView.bottomAnchor, multiplier: 1),
      inputSchemaFileDocumentPickButton.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: inputSchemaFileDocumentPickButton.trailingAnchor, multiplier: 1),

      uploadButton.topAnchor.constraint(equalToSystemSpacingBelow: inputSchemaFileDocumentPickButton.bottomAnchor, multiplier: 1),
      uploadButton.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: uploadButton.trailingAnchor, multiplier: 1),

      remarkLabel.topAnchor.constraint(equalToSystemSpacingBelow: uploadButton.bottomAnchor, multiplier: 1),
      remarkLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.contentLayoutGuide.leadingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: remarkLabel.trailingAnchor, multiplier: 1),
      scrollView.contentLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: remarkLabel.bottomAnchor, multiplier: 1),
    ])
  }

  override func setupAppearance() {
    backgroundColor = .secondarySystemBackground
  }

  func combine() {
    inputSchemaViewModel.uploadInputSchemaPickerFileSubject
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        // print("picker file: \($0.path)")
        self.inputSchemaFileURL = $0
      }
      .store(in: &subscriptions)
  }

  @objc func presentDocumentPickerView(_ sender: Any) {
    inputSchemaViewModel.presentUploadInputSchemaZipFileSubject.send(true)
  }

  @objc func uploadInputSchema(_ sender: Any) {
    guard let title = self.titleField.text, !title.isEmpty else {
      ProgressHUD.error("请输入方案名称")
      titleField.becomeFirstResponder()
      return
    }

    guard let author = self.authorField.text, !author.isEmpty else {
      ProgressHUD.error("请输入方案作者")
      titleField.becomeFirstResponder()
      return
    }

    guard let desc = self.descriptionTextView.text, !desc.isEmpty else {
      ProgressHUD.error("请输入方案描述")
      descriptionTextView.becomeFirstResponder()
      return
    }

    guard let fileURL = self.inputSchemaFileURL else {
      ProgressHUD.error("请选择需要上传的方案文件")
      return
    }

    Task {
      
      await inputSchemaViewModel.uploadInputSchema(title: title, author: author, description: desc, fileURL: fileURL)
    }
  }
}
