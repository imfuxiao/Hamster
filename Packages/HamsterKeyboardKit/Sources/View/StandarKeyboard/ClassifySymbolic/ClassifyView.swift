//
//  ClassifyView.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import UIKit

/// 符号分类显示视图
class ClassifyView: UICollectionView {
  private let keyboardContext: KeyboardContext
  private let viewModel: ClassifySymbolicViewModel
  
  private var userInterfaceStyle: UIUserInterfaceStyle!
  
  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, SymbolCategory>!
  private var subscriptions = Set<AnyCancellable>()
  
  init(keyboardContext: KeyboardContext, viewModel: ClassifySymbolicViewModel) {
    self.keyboardContext = keyboardContext
    self.viewModel = viewModel
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, layoutEnvironment in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.separatorConfiguration.color = keyboardContext.enableHamsterKeyboardColor ? .systemGray : .secondarySystemBackground
      let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
      section.contentInsets = .zero
      return section
    })
    
    self.userInterfaceStyle = keyboardContext.traitCollection.userInterfaceStyle
    
    super.init(frame: .zero, collectionViewLayout: layout)
    
    self.backgroundColor = keyboardContext.symbolListBackgroundColor
    self.delegate = self
    self.diffableDataSource = makeDataSource()
    
    // init data
    var snapshot = NSDiffableDataSourceSnapshot<Int, SymbolCategory>()
    snapshot.appendSections([0])
    snapshot.appendItems(SymbolCategory.all, toSection: 0)
    diffableDataSource.apply(snapshot, animatingDifferences: false)
    
    if keyboardContext.keyboardType.isChinese {
      viewModel.currentCategory = .cn
      selectItem(at: IndexPath(item: 2, section: 0), animated: false, scrollPosition: .top)
    } else {
      viewModel.currentCategory = .ascii
      selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .top)
    }
    
    keyboardContext.$traitCollection
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        setNeedsLayout()
      }
      .store(in: &subscriptions)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    guard userInterfaceStyle != keyboardContext.traitCollection.userInterfaceStyle else { return }
    userInterfaceStyle = traitCollection.userInterfaceStyle

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
        highlightedColor: keyboardContext.symbolListHighlightedBackgroundColor,
//        normalColor: keyboardContext.symbolListBackgroundColor,
        normalColor: .clear,
        labelHighlightColor: .label,
        labelNormalColor: keyboardContext.candidateTextColor
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
    let item = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    viewModel.currentCategory = item
    collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
  }
}
