//
//  StanderSystemKeyboardSettingsView.swift
//
//
//  Created by morse on 2023/9/13.
//

import HamsterUIKit
import UIKit

/// 中文标准键盘设置
class ChineseStanderSystemKeyboardSettingsView: NibLessCollectionView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  private var diffableDataSource: UICollectionViewDiffableDataSource<SettingSectionModel, SettingItemModel>!

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    super.init(frame: .zero, collectionViewLayout: layout)

    self.diffableDataSource = makeDataSource()
    diffableDataSource.apply(keyboardSettingsViewModel.initChineseStanderSystemKeyboardDataSource(), animatingDifferences: false)
  }

  func cellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SettingItemModel> {
    UICollectionView.CellRegistration { cell, _, item in
      var configuration = cell.defaultContentConfiguration()
      configuration.text = item.text
      cell.contentConfiguration = configuration
    }
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<SettingSectionModel, SettingItemModel> {
    let cellRegistration = cellRegistration()
    return UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }
}
