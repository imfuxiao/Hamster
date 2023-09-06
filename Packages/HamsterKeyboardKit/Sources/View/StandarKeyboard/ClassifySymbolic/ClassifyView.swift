//
//  ClassifyView.swift
//
//
//  Created by morse on 2023/9/5.
//

import UIKit

/// 符号分类显示视图
class ClassifyView: UICollectionView {
  private let keyboardContext: KeyboardContext
  private let viewModel: ClassifySymbolicViewModel
  
  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, SymbolCategory>!
  
  init(keyboardContext: KeyboardContext, viewModel: ClassifySymbolicViewModel) {
    self.keyboardContext = keyboardContext
    self.viewModel = viewModel
    
    let layout: UICollectionViewCompositionalLayout = {
      let categoryItem = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(1.0)
        )
      )
      
      let categoryGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(0.25)
        ),
        subitems: [categoryItem]
      )
      categoryGroup.edgeSpacing = .init(leading: .none, top: .none, trailing: .none, bottom: .fixed(1))
      
      let section = NSCollectionLayoutSection(group: categoryGroup)
      return UICollectionViewCompositionalLayout(section: section)
    }()
    
    super.init(frame: .zero, collectionViewLayout: layout)
    
    self.delegate = self
    self.diffableDataSource = makeDataSource()
    
    // init data
    var snapshot = NSDiffableDataSourceSnapshot<Int, SymbolCategory>()
    snapshot.appendSections([0])
    snapshot.appendItems(SymbolCategory.all, toSection: 0)
    diffableDataSource.apply(snapshot, animatingDifferences: false)
    selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, SymbolCategory> {
    let symbolCellRegistration = UICollectionView.CellRegistration<ClassifySymbolCell, SymbolCategory> { cell, _, symbol in
      var config = UIListContentConfiguration.valueCell()
      // TODO: 符号分类国际化
      // config.text = KKL10n.text(forKey: symbol.rawValue, locale: keyboardContext.locale)
      config.text = symbol.string
      cell.contentConfiguration = config
    }
    
    let dataSource = UICollectionViewDiffableDataSource<Int, SymbolCategory>(collectionView: self) { collectionView, indexPath, symbol in
      collectionView.dequeueConfiguredReusableCell(using: symbolCellRegistration, for: indexPath, item: symbol)
    }
    return dataSource
  }
}

extension ClassifyView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    viewModel.currentCategory = item
    collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
  }
}
