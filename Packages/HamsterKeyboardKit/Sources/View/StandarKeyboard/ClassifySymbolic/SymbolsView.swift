//
//  SymbolsView.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import UIKit

/// 符号显示视图
class SymbolsView: UICollectionView {
  let keyboardContext: KeyboardContext
  let actionHandler: KeyboardActionHandler
  let viewModel: ClassifySymbolicViewModel
  var subscriptions = Set<AnyCancellable>()

  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, Symbol>!

  init(keyboardContext: KeyboardContext, actionHandler: KeyboardActionHandler, viewModel: ClassifySymbolicViewModel) {
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    self.viewModel = viewModel

    let layout: UICollectionViewCompositionalLayout = {
      let symbolItem = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(0.25),
          heightDimension: .fractionalHeight(1.0)
        )
      )

      let symbolGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(0.25)
        ),
        subitems: [symbolItem, symbolItem, symbolItem, symbolItem]
      )
      symbolGroup.edgeSpacing = .init(leading: .none, top: .none, trailing: .none, bottom: .fixed(1))

      let section = NSCollectionLayoutSection(group: symbolGroup)
      section.contentInsets = .zero
      section.interGroupSpacing = .zero
      return UICollectionViewCompositionalLayout(section: section)
    }()

    super.init(frame: .zero, collectionViewLayout: layout)

    self.backgroundColor = .clear
    self.delegate = self
    self.diffableDataSource = makeDataSource()

    // init data
    diffableDataSource.apply(makeSnapshot(symbols: viewModel.currentCategory.symbols), animatingDifferences: false)
    scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)

    viewModel.$currentCategory
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        diffableDataSource.apply(makeSnapshot(symbols: $0.symbols), animatingDifferences: false)
        self.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
      }
      .store(in: &subscriptions)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, Symbol> {
    let symbolCellRegistration = UICollectionView.CellRegistration<ClassifySymbolCell, Symbol> { [unowned self] cell, _, symbol in
      cell.textLabel.text = symbol.char
      cell.textLabel.textColor = keyboardContext.candidateTextColor
      cell.normalColor = keyboardContext.symbolListBackgroundColor
      cell.highlightedColor = keyboardContext.symbolListHighlightedBackgroundColor
    }

    let dataSource = UICollectionViewDiffableDataSource<Int, Symbol>(collectionView: self) { collectionView, indexPath, symbol in
      collectionView.dequeueConfiguredReusableCell(using: symbolCellRegistration, for: indexPath, item: symbol)
    }
    return dataSource
  }

  func makeSnapshot(symbols: [Symbol]) -> NSDiffableDataSourceSnapshot<Int, Symbol> {
    var snapshot = NSDiffableDataSourceSnapshot<Int, Symbol>()
    snapshot.appendSections([0])
    snapshot.appendItems(symbols, toSection: 0)
    return snapshot
  }
}

extension SymbolsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let item = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    actionHandler.handle(.press, on: .symbol(item))
    return true
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    actionHandler.handle(.release, on: .symbol(item))
    collectionView.deselectItem(at: indexPath, animated: true)
    if !keyboardContext.classifySymbolKeyboardLockState {
      actionHandler.handle(.release, on: .returnLastKeyboard)
    }
  }
}
