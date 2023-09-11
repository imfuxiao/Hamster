//
//  SymbolsVerticalView.swift
//
//
//  Created by morse on 2023/9/6.
//

import UIKit

/// 垂直滑动符号列表
class SymbolsVerticalView: UICollectionView {
  typealias initDataBuilder = (UICollectionViewDiffableDataSource<Int, String>) -> Void

  // MARK: - Properties

  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler

  public var diffalbeDataSource: UICollectionViewDiffableDataSource<Int, String>!

  // MARK: - 计算属性

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Initialization

  init(keyboardContext: KeyboardContext, actionHandler: KeyboardActionHandler, initDataBuilder: initDataBuilder) {
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, layoutEnvironment in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .standardDarkButtonBackground
      let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
      section.contentInsets = .zero
      return section
    })
    super.init(frame: .zero, collectionViewLayout: layout)

    self.diffalbeDataSource = makeDataSource()
    self.showsVerticalScrollIndicator = false

    // init data
    initDataBuilder(self.diffalbeDataSource)

    // 圆角样式
    self.layer.cornerRadius = layoutConfig.buttonCornerRadius
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functional

  func symbolCellRegistration() -> UICollectionView.CellRegistration<SymbolCell, String> {
    UICollectionView.CellRegistration { cell, _, item in
      cell.textLabel.text = item
    }
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
    let cellRegistration = symbolCellRegistration()
    return UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }
}
