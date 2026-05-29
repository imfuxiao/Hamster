//
//  GifPanelView.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import HamsterUIKit
import UIKit

/// GIF 斗图面板视图
class GifPanelView: NibLessView {
  private let style: CandidateBarStyle

  /// 搜索回调
  var onSearch: ((String) -> Void)?

  /// 标签点击回调
  var onTagTapped: ((String) -> Void)?

  /// 更新标签回调
  var onUpdateTags: (([String]) -> Void)?

  /// GIF 选择回调
  var onGifSelected: ((GifResult) -> Void)?

  lazy var scrollView: UIScrollView = {
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    return scroll
  }()

  lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var stackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 16
    return stack
  }()

  // 搜索栏
  lazy var searchBarContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var searchTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "搜索 GIF..."
    textField.borderStyle = .roundedRect
    textField.font = .systemFont(ofSize: 14)
    return textField
  }()

  lazy var searchButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("搜索", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 8
    return button
  }()

  // 标签区域
  lazy var tagsContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var tagsStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.spacing = 8
    stack.distribution = .fill
    return stack
  }()

  // GIF 网格
  lazy var gifGridContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var gifCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 80, height: 80)
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    layout.scrollDirection = .vertical

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .clear
    collectionView.register(GifCell.self, forCellWithReuseIdentifier: "GifCell")
    collectionView.dataSource = self
    collectionView.delegate = self
    return collectionView
  }()

  private var gifResults: [GifResult] = []

  init(style: CandidateBarStyle) {
    self.style = style
    super.init(frame: .zero)
    setupSubview()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubview() {
    backgroundColor = style.toolbarButtonBackgroundColor

    // 搜索栏
    searchBarContainer.addSubview(searchTextField)
    searchBarContainer.addSubview(searchButton)
    NSLayoutConstraint.activate([
      searchTextField.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor),
      searchTextField.topAnchor.constraint(equalTo: searchBarContainer.topAnchor),
      searchTextField.bottomAnchor.constraint(equalTo: searchBarContainer.bottomAnchor),
      searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 8),
      searchButton.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor),
      searchButton.topAnchor.constraint(equalTo: searchBarContainer.topAnchor),
      searchButton.bottomAnchor.constraint(equalTo: searchBarContainer.bottomAnchor),
      searchButton.widthAnchor.constraint(equalToConstant: 60),
      searchBarContainer.heightAnchor.constraint(equalToConstant: 44),
    ])

    // 标签
    let tags = ["搞笑", "开心", "惊讶", "点赞"]
    for (index, tag) in tags.enumerated() {
      let tagButton = createTagButton(title: tag, isAI: false)
      tagButton.tag = index
      tagButton.addTarget(self, action: #selector(handleTagTapped(_:)), for: .touchUpInside)
      tagsStackView.addArrangedSubview(tagButton)
    }

    tagsContainer.addSubview(tagsStackView)
    NSLayoutConstraint.activate([
      tagsStackView.topAnchor.constraint(equalTo: tagsContainer.topAnchor),
      tagsStackView.bottomAnchor.constraint(equalTo: tagsContainer.bottomAnchor),
      tagsStackView.leadingAnchor.constraint(equalTo: tagsContainer.leadingAnchor),
      tagsStackView.trailingAnchor.constraint(equalTo: tagsContainer.trailingAnchor),
      tagsContainer.heightAnchor.constraint(equalToConstant: 40),
    ])

    // GIF 网格
    gifGridContainer.addSubview(gifCollectionView)
    NSLayoutConstraint.activate([
      gifCollectionView.topAnchor.constraint(equalTo: gifGridContainer.topAnchor),
      gifCollectionView.bottomAnchor.constraint(equalTo: gifGridContainer.bottomAnchor),
      gifCollectionView.leadingAnchor.constraint(equalTo: gifGridContainer.leadingAnchor),
      gifCollectionView.trailingAnchor.constraint(equalTo: gifGridContainer.trailingAnchor),
      gifGridContainer.heightAnchor.constraint(equalToConstant: 240),
    ])

    // 添加到主栈视图
    stackView.addArrangedSubview(searchBarContainer)
    stackView.addArrangedSubview(tagsContainer)
    stackView.addArrangedSubview(gifGridContainer)

    contentView.addSubview(stackView)
    scrollView.addSubview(contentView)
    addSubview(scrollView)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    ])

    // 添加搜索按钮点击事件
    searchButton.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)
  }

  @objc func handleSearch() {
    guard let searchText = searchTextField.text, !searchText.isEmpty else { return }
    onSearch?(searchText)
  }

  @objc func handleTagTapped(_ sender: UIButton) {
    guard let tagTitle = sender.titleLabel?.text else { return }
    onTagTapped?(tagTitle)
  }

  func updateGifResults(_ results: [GifResult]) {
    self.gifResults = results
    gifCollectionView.reloadData()
  }

  func updateTags(_ tags: [String]) {
    // 清除现有标签
    for view in tagsStackView.arrangedSubviews {
      tagsStackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }

    // 添加新标签
    for (index, tag) in tags.enumerated() {
      let tagButton = createTagButton(title: tag, isAI: true)
      tagButton.tag = index
      tagButton.addTarget(self, action: #selector(handleTagTapped(_:)), for: .touchUpInside)
      tagsStackView.addArrangedSubview(tagButton)
    }
  }

  func createTagButton(title: String, isAI: Bool) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 13)
    button.layer.cornerRadius = 16
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    if isAI {
      button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
      button.setTitleColor(.systemBlue, for: .normal)
    } else {
      button.backgroundColor = .systemGray6
      button.setTitleColor(.label, for: .normal)
    }

    return button
  }
}

// MARK: - UICollectionViewDataSource
extension GifPanelView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return gifResults.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as? GifCell else {
      return UICollectionViewCell()
    }
    let gif = gifResults[indexPath.item]
    cell.configure(gif: gif)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension GifPanelView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let gif = gifResults[indexPath.item]
    onGifSelected?(gif)
  }
}

/// GIF 单元格
class GifCell: UICollectionViewCell {
  lazy var gifImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()

  lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemGray6
    view.layer.cornerRadius = 8
    return view
  }()

  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupSubview()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubview() {
    containerView.addSubview(gifImageView)
    containerView.addSubview(activityIndicator)
    contentView.addSubview(containerView)

    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

      gifImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
      gifImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      gifImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      gifImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

      activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
    ])
  }

  func configure(gif: GifResult) {
    activityIndicator.startAnimating()
    
    // 优先使用预览图，否则使用原图
    let urlString = gif.previewUrl ?? gif.url
    guard let url = URL(string: urlString) else {
      activityIndicator.stopAnimating()
      return
    }
    
    // 下载图片
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      DispatchQueue.main.async {
        self?.activityIndicator.stopAnimating()
        if let data = data, let image = UIImage(data: data) {
          self?.gifImageView.image = image
        }
      }
    }.resume()
  }
}
