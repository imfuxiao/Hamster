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
  var style: NonStandardKeyboardStyle
  let keyboardContext: KeyboardContext
  let actionHandler: KeyboardActionHandler
  let viewModel: ClassifySymbolicViewModel
  var subscriptions = Set<AnyCancellable>()
  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, Symbol>!

  init(style: NonStandardKeyboardStyle, keyboardContext: KeyboardContext, actionHandler: KeyboardActionHandler, viewModel: ClassifySymbolicViewModel) {
    self.style = style
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    self.viewModel = viewModel

    let layout = {
      let layout = SeparatorCollectionViewFlowLayout()
      layout.scrollDirection = .vertical
      return layout
    }()

    super.init(frame: .zero, collectionViewLayout: layout)

    self.alwaysBounceVertical = true
    self.delegate = self
    self.diffableDataSource = makeDataSource()

    setupAppearance()

    // init data
    diffableDataSource.apply(makeSnapshot(symbols: viewModel.currentCategory.symbols), animatingDifferences: false)
    scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)

    combine()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupAppearance() {
    self.backgroundColor = style.backgroundColor
  }

  func reloadDiffableData() {
    var snapshot = diffableDataSource.snapshot()
    snapshot.reloadSections([0])
    diffableDataSource.apply(snapshot)
  }

  func setStyle(_ style: NonStandardKeyboardStyle) {
    self.style = style
    setupAppearance()
    reloadDiffableData()
  }

  func combine() {
    viewModel.$currentCategory
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        diffableDataSource.apply(makeSnapshot(symbols: $0.symbols), animatingDifferences: false)
        self.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
      }
      .store(in: &subscriptions)
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, Symbol> {
    let symbolCellRegistration = UICollectionView.CellRegistration<SymbolCell, Symbol> { [unowned self] cell, _, symbol in
      // TODO: 符号分类国际化
      // cell.text = KKL10n.text(forKey: symbol.rawValue, locale: keyboardContext.locale)
      cell.updateWithSymbol(
        symbol.char,
        style: style
      )
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
    guard let _ = collectionView.cellForItem(at: indexPath) else { return }
    let item = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    collectionView.deselectItem(at: indexPath, animated: true)
    if !keyboardContext.classifySymbolKeyboardLockState {
      actionHandler.handle(.release, on: .returnLastKeyboard)
    }
    actionHandler.handle(.release, on: .symbol(item))
  }
}

extension SymbolsView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    .horizontal(6, vertical: 6)
  }

  // 询问委托一个部分连续的行或列之间的间距。
  // 对于一个垂直滚动的网格，这个值表示连续的行之间的最小间距。
  // 对于一个水平滚动的网格，这个值代表连续的列之间的最小间距。
  // 这个间距不应用于标题和第一行之间的空间或最后一行和页脚之间的空间。
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }

  // 向委托询问某部分的行或列中连续项目之间的间距。
  // 你对这个方法的实现可以返回一个固定的值或者为每个部分返回不同的间距值。
  // 对于一个垂直滚动的网格，这个值代表了同一行中项目之间的最小间距。
  // 对于一个水平滚动的网格，这个值代表同一列中项目之间的最小间距。
  // 这个间距是用来计算单行可以容纳多少个项目的，但是在确定了项目的数量之后，实际的间距可能会被向上调整。
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 15
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 40, height: 40)
  }
}
