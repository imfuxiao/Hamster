//
//  CustomKeyboardSettingsView.swift
//
//
//  Created by morse on 2023/9/14.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

/// 自定义键盘设置
class CustomKeyboardSettingsView: NibLessCollectionView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, KeyboardType>!

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
      let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
      return section
    }

    super.init(frame: .zero, collectionViewLayout: layout)

    self.delegate = self
    self.diffableDataSource = makeDataSource()
//    self.diffableDataSource.apply(keyboardSettingsViewModel.initCustomizerKeyboardLayoutDataSource(), animatingDifferences: false)

    if let index = self.diffableDataSource.snapshot(for: 0).items.firstIndex(where: { $0 == keyboardSettingsViewModel.useKeyboardType }) {
      self.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredVertically)
    }
  }
}

extension CustomKeyboardSettingsView {
  func cellRegistration() -> UICollectionView.CellRegistration<KeyboardLayoutCell, KeyboardType> {
    UICollectionView.CellRegistration { cell, _, item in
      cell.label.text = item.label
    }
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, KeyboardType> {
    let cellRegistration = cellRegistration()
    return UICollectionViewDiffableDataSource(
      collectionView: self,
      cellProvider: { collectionView, indexPath, item in
        collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration,
          for: indexPath,
          item: item
        )
      }
    )
  }
}

extension CustomKeyboardSettingsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let _ = collectionView.cellForItem(at: indexPath) else { return }
    let keyboardType = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    keyboardSettingsViewModel.useKeyboardType = keyboardType
  }
}
