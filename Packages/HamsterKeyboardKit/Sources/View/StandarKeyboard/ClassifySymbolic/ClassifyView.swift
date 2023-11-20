//
//  ClassifyView.swift
//
//
//  Created by morse on 2023/9/5.
//

import UIKit

/// 符号分类显示视图
class ClassifyView: UICollectionView {
  private var style: NonStandardKeyboardStyle
  private let keyboardContext: KeyboardContext
  private let viewModel: ClassifySymbolicViewModel
  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, SymbolCategory>!

  init(style: NonStandardKeyboardStyle, keyboardContext: KeyboardContext, viewModel: ClassifySymbolicViewModel) {
    self.keyboardContext = keyboardContext
    self.viewModel = viewModel
    self.style = style

    let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, layoutEnvironment in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.separatorConfiguration.color = .secondarySystemFill
      let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
      section.contentInsets = .zero
      return section
    })

    super.init(frame: .zero, collectionViewLayout: layout)

    setupAppearance()

    self.delegate = self
    self.diffableDataSource = makeDataSource()

    // init data
    var snapshot = NSDiffableDataSourceSnapshot<Int, SymbolCategory>()
    snapshot.appendSections([0])
    snapshot.appendItems(SymbolCategory.all, toSection: 0)
    diffableDataSource.apply(snapshot, animatingDifferences: false)

    if keyboardContext.selectKeyboard.isChinese {
      viewModel.currentCategory = .cn
      selectItem(at: IndexPath(item: 2, section: 0), animated: false, scrollPosition: .top)
    } else {
      viewModel.currentCategory = .frequent
      selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupAppearance() {
    self.backgroundColor = style.backgroundColor
  }

  func setStyle(_ style: NonStandardKeyboardStyle) {
    self.style = style

    setupAppearance()
    reloadDiffableDataSource()
  }

  func reloadDiffableDataSource() {
    var snapshot = diffableDataSource.snapshot()
    snapshot.reloadSections([0])
    diffableDataSource.apply(snapshot, animatingDifferences: false)
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, SymbolCategory> {
    let symbolCellRegistration = UICollectionView.CellRegistration<SymbolCell, SymbolCategory> { [unowned self] cell, _, symbol in
      // TODO: 符号分类国际化
      // cell.text = KKL10n.text(forKey: symbol.rawValue, locale: keyboardContext.locale)
      cell.updateWithSymbol(
        symbol.string,
        style: style
      )
    }

    let dataSource = UICollectionViewDiffableDataSource<Int, SymbolCategory>(collectionView: self) { collectionView, indexPath, symbol in
      collectionView.dequeueConfiguredReusableCell(using: symbolCellRegistration, for: indexPath, item: symbol)
    }
    return dataSource
  }
}

extension ClassifyView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let _ = collectionView.cellForItem(at: indexPath) else { return }
    let item = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    viewModel.currentCategory = item
    collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
  }
}
