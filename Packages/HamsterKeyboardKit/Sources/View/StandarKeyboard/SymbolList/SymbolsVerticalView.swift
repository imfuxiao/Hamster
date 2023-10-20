//
//  SymbolsVerticalView.swift
//
//
//  Created by morse on 2023/9/6.
//

import UIKit

/// 垂直划动符号列表
class SymbolsVerticalView: UICollectionView {
  typealias InitDataBuilder = (UICollectionViewDiffableDataSource<Int, String>) -> Void

  // MARK: - Properties

  private var style: NonStandardKeyboardStyle
  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler
  private let dataBuilder: InitDataBuilder

  public var diffalbeDataSource: UICollectionViewDiffableDataSource<Int, String>!

  // MARK: - 计算属性

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

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
    self.layer.cornerRadius = layoutConfig.buttonCornerRadius
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupAppearance() {
    self.backgroundColor = style.backgroundColor

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
