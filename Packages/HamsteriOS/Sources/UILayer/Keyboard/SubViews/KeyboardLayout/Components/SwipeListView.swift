//
//  SwipeListView.swift
//
//
//  Created by morse on 2023/10/18.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

/// 键盘划动列表
class SwipeListView: NibLessCollectionView {
  public var diffableDataSource: UICollectionViewDiffableDataSource<Int, Key>!

  init(loadDataSource: (UICollectionViewDiffableDataSource<Int, Key>) -> Void) {
    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    super.init(frame: .zero, collectionViewLayout: layout)

    self.diffableDataSource = makeDataSource()
    loadDataSource(self.diffableDataSource)
  }

  func cellRegistration() -> UICollectionView.CellRegistration<SwipeSettingsCell, Key> {
    return UICollectionView.CellRegistration { cell, _, item in
      cell.updateWithKey(item)
    }
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, Key> {
    let cellRegistration = cellRegistration()
    return UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }
}
