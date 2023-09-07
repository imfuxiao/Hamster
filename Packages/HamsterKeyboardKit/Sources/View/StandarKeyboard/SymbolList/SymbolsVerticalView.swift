//
//  SymbolsVerticalView.swift
//
//
//  Created by morse on 2023/9/6.
//

import UIKit

/// 垂直滑动符号列表
class SymbolsVerticalView: UICollectionView {
  // MARK: - Properties

  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler

  private var diffalbeDataSource: UICollectionViewDiffableDataSource<Int, String>!

  // MARK: - 计算属性

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Initialization

  init(keyboardContext: KeyboardContext, actionHandler: KeyboardActionHandler) {
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
    self.delegate = self
    self.showsVerticalScrollIndicator = false

    // init data
    var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
    snapshot.appendSections([0])
    snapshot.appendItems(keyboardContext.symbolsOfNumericNineGridKeyboard, toSection: 0)
    diffalbeDataSource.apply(snapshot, animatingDifferences: false)

    self.layer.cornerRadius = layoutConfig.buttonCornerRadius
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functional

  func symbolCellRegistration() -> UICollectionView.CellRegistration<SymbolCell, String> {
    UICollectionView.CellRegistration { cell, _, item in
      var configuration = cell.defaultContentConfiguration()
      configuration.text = item
      configuration.textProperties.alignment = .center
      cell.contentConfiguration = configuration
    }
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
    let cellRegistration = symbolCellRegistration()
    return UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }
}

extension SymbolsVerticalView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    print("collectionView shouldSelectItemAt")
    let symbol = diffalbeDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    actionHandler.handle(.press, on: .symbol(.init(char: symbol)))
    return true
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("collectionView didSelectItemAt")
    let symbol = diffalbeDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    actionHandler.handle(.release, on: .symbol(.init(char: symbol)))
    collectionView.deselectItem(at: indexPath, animated: true)
  }
}
