//
//  SymbolsVerticalView.swift
//
//
//  Created by morse on 2023/9/6.
//

import HamsterUIKit
import UIKit

/// 垂直划动符号列表
class SymbolsVerticalView: NibLessView {
  typealias InitDataBuilder = (UICollectionViewDiffableDataSource<Int, String>) -> Void

  // MARK: - Properties

  override class var layerClass: AnyClass {
    CAShapeLayer.self
  }

  private var shapeLayer: CAShapeLayer!
  private var style: NonStandardKeyboardStyle
  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler
  private let dataBuilder: InitDataBuilder
  private var oldFrame: CGRect!

  public var diffalbeDataSource: UICollectionViewDiffableDataSource<Int, String> {
    symbolsVerticalListView.diffalbeDataSource
  }

  private var collectionDelegateBuilder: () -> UICollectionViewDelegate

  /// 符号列表视图
  private lazy var symbolsVerticalListView: SymbolsVerticalListView = {
    let view = SymbolsVerticalListView(style: style, keyboardContext: keyboardContext, actionHandler: actionHandler, dataBuilder: dataBuilder)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = collectionDelegateBuilder()
    return view
  }()

  // MARK: - Initialization

  init(
    style: NonStandardKeyboardStyle,
    keyboardContext: KeyboardContext,
    actionHandler: KeyboardActionHandler,
    dataBuilder: @escaping InitDataBuilder,
    collectionDelegateBuilder: @escaping () -> UICollectionViewDelegate
  ) {
    self.style = style
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    self.dataBuilder = dataBuilder
    self.collectionDelegateBuilder = collectionDelegateBuilder

    super.init(frame: .zero)

    self.shapeLayer = layer as? CAShapeLayer

    self.oldFrame = self.frame

    setupView()
    setupAppearance()
  }

  override func constructViewHierarchy() {
    addSubview(symbolsVerticalListView)
  }

  override func activateViewConstraints() {
    symbolsVerticalListView.fillSuperview()
  }

  func setupView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  override func setupAppearance() {
    if self.oldFrame != self.frame, self.frame != .zero {
      self.oldFrame = self.frame

      // 底部阴影边框
      self.shapeLayer.fillColor = style.shadowColor.cgColor
      self.shapeLayer.path = underPath.cgPath
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    setupAppearance()
  }

  func setStyle(_ style: NonStandardKeyboardStyle) {
    self.style = style
    self.symbolsVerticalListView.setStyle(style)

    setupAppearance()
  }

  /// 底部深色样式路径
  var underPath: UIBezierPath {
    CAShapeLayer.underPath(size: CGSize(width: frame.size.width, height: frame.size.height + 1), cornerRadius: style.cornerRadius)
  }
}

private class SymbolsVerticalListView: UICollectionView {
  typealias InitDataBuilder = (UICollectionViewDiffableDataSource<Int, String>) -> Void

  // MARK: - Properties

  private var style: NonStandardKeyboardStyle
  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler
  private let dataBuilder: InitDataBuilder

  public var diffalbeDataSource: UICollectionViewDiffableDataSource<Int, String>!

  // MARK: - Initialization

  init(style: NonStandardKeyboardStyle, keyboardContext: KeyboardContext, actionHandler: KeyboardActionHandler, dataBuilder: @escaping InitDataBuilder) {
    self.style = style
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, layoutEnvironment in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.separatorConfiguration.color = .secondarySystemFill
      let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
      section.contentInsets = .zero
      section.interGroupSpacing = .zero
      return section
    })
    self.dataBuilder = dataBuilder

    super.init(frame: .zero, collectionViewLayout: layout)

    self.diffalbeDataSource = makeDataSource()
    self.showsVerticalScrollIndicator = false

    setupAppearance()

    // 圆角样式
    self.layer.cornerRadius = style.cornerRadius
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupAppearance() {
    self.backgroundColor = style.backgroundColor
    if let color = style.borderColor {
      self.layer.borderColor = color.cgColor
      self.layer.borderWidth = 1
    }

    dataBuilder(self.diffalbeDataSource)
  }

  func setStyle(_ style: NonStandardKeyboardStyle) {
    self.style = style

    setupAppearance()
  }

  // MARK: - Functional

  func symbolCellRegistration() -> UICollectionView.CellRegistration<SymbolCell, String> {
    UICollectionView.CellRegistration { [unowned self] cell, _, item in
      cell.updateWithSymbol(item, style: style)
    }
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
    let cellRegistration = symbolCellRegistration()
    return UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }
}
